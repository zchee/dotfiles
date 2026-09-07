"""kitty watcher: repaint colour literals on screen with the colour they name.

    kitty.conf:  watcher kitten/hex_colorizer.py

Recognises `#RRGGBB` and every colour NAME kitty itself knows -- red, yellow,
orange and the rest of the X11 set, including its numbered variants (red3,
grey37, antiquewhite2). Names are resolved through kitty's own
Color.parse_color, so this file carries no copy of the table, only a cache of
the words it has already looked up. Bare hex without a '#' is not a colour to
parse_color, so ordinary words made of hex letters (fade, beef, deface) do not
false-positive.

Note that a name is matched wherever it appears as a whole word, so the word
"red" in prose is painted too. Put the names you do not want treated as
colours into NAME_EXCLUDE.

The colour is written straight into the live GPUCell fg/bg via
Line.apply_cursor, so it reaches the renderer with no C-side change. This is
destructive by design: the application's own colours for those cells are
replaced until it redraws them, at which point the next tick repaints.

Scope is the visible windows of each OS window's active tab. Hidden tabs and
windows are skipped, so cost tracks what is actually on screen. Painting only
the focused split instead would make the colours appear and disappear as focus
moves between splits, which is a worse flicker than the one being avoided --
set SCOPE = 'active' if that is what you want anyway.
"""

from __future__ import annotations

import logging
import re
from typing import Any

from kitty.boss import Boss
from kitty.rgb import to_color

try:
    from kitty.fast_data_types import add_timer
except ImportError:  # pragma: no cover - only missing outside a kitty process
    add_timer = None

HEX = re.compile(r"#([0-9a-fA-F]{6})(?![0-9a-fA-F])")
# Candidate colour names. Only the shape is matched here; whether a word IS a
# colour is kitty's call, in name_rgb() below. '_' is a word character to the
# regex engine's \w but not part of this class, so `fg_red` still offers `red`.
NAME = re.compile(r"[A-Za-z][A-Za-z0-9]{2,23}")
NAME_EXCLUDE: frozenset[str] = frozenset()
INTERVAL = 0.016  # s, one tick per 60Hz frame
LUMA_SPLIT = 140.0
# Annotated as str, not left to infer Literal["visible"]: it is a knob, and a
# literal type makes a checker call the other two branches dead code.
SCOPE: str = "visible"  # 'visible' | 'active' | 'all'

logger = logging.getLogger(__name__)

_name_cache: dict[str, int | None] = {}
_NAME_CACHE_MAX = 20000
_span_cache: dict[str, list[tuple[int, int, int]]] = {}
_SPAN_CACHE_MAX = 8192


def as_rgb(x: int) -> int:
    return (x << 8) | 2


def name_rgb(word: str) -> int | None:
    """Packed 0xRRGGBB for a colour name, or None. Memoised per distinct word.

    Steady state is a dict hit: a word costs one parse_color call once, ever.
    """
    key = word.lower()
    try:
        return _name_cache[key]
    except KeyError:
        pass
    rgb = None
    if key not in NAME_EXCLUDE:
        col = to_color(key)
        if col is not None:
            rgb = (col.red << 16) | (col.green << 8) | col.blue
    if len(_name_cache) >= _NAME_CACHE_MAX:
        _name_cache.clear()
    _name_cache[key] = rgb
    return rgb


def find_spans(text: str) -> list[tuple[int, int, int]]:
    """(start, end, rgb) for every colour literal, ordered, non-overlapping.

    Hex wins over names on overlap, so a name that happens to sit inside a hex
    token cannot repaint part of it.

    Memoised on the line text: a screen mostly repeats itself tick to tick, and
    scanning every word of every line at 62.5 Hz is the dominant cost
    otherwise (measured 335 us/tick for 50 lines of plain prose, vs 34 with
    this cache).
    """
    try:
        return _span_cache[text]
    except KeyError:
        pass
    spans = _find_spans(text)
    if len(_span_cache) >= _SPAN_CACHE_MAX:
        _span_cache.clear()
    _span_cache[text] = spans
    return spans


def _find_spans(text: str) -> list[tuple[int, int, int]]:
    spans = [(m.start(), m.end(), int(m.group(1), 16)) for m in HEX.finditer(text)]
    taken = {i for s, e, _ in spans for i in range(s, e)}
    for m in NAME.finditer(text):
        rgb = name_rgb(m.group(0))
        if rgb is None:
            continue
        if not taken.isdisjoint(range(m.start(), m.end())):
            continue
        spans.append((m.start(), m.end(), rgb))
    spans.sort()
    return spans


def text_and_cellmap(line: Any, cols: int) -> tuple[str, list[int]]:
    """Build the line text from cells so char offsets map back to CELL offsets.

    str(line) collapses a wide char to one character while it occupies two
    cells, and a tab to one character while it may occupy many, so a regex
    offset taken from it drifts. Walking cells keeps the two in step.

    Line.__getitem__ is the authority on cell content: '' only ever means a
    multicell continuation cell, '\\0' means a cell holding no text, and a tab
    cell carries its skip count as a second pseudo-character. Note that
    Line.width() is deliberately not used -- on kitty builds before the
    line.c:720 fix it raises SystemError for a cell with no text, and after
    that fix it returns 0 for both blank and continuation cells, which are the
    two cases that must be told apart.
    """
    parts: list[str] = []
    cmap: list[int] = []
    for x in range(cols):
        s = line[x]
        if not s:
            continue  # continuation cell of a multicell/wide char
        c = s[0]
        if c == "\0":
            s = " "  # cell holding no text
        elif c == "\t":
            s = "\t"  # drop the tab's trailing skip-count pseudo-char
        parts.append(s)
        cmap.extend([x] * len(s))
    return "".join(parts), cmap


def cells_spell(line: Any, x0: int, token: str, cols: int) -> bool:
    """Do the cells from x0 actually hold `token`?"""
    if x0 < 0 or x0 + len(token) > cols:
        return False
    return all(line[x0 + i][:1] == ch for i, ch in enumerate(token))


def paint_spans(line: Any, spans: list[tuple[int, int, int]], cmap: Any) -> int:
    changed = 0
    for start, end, rgb in spans:
        x0 = start if cmap is None else cmap[start]
        x1 = (end - 1 if cmap is None else cmap[end - 1]) + 1
        bg = as_rgb(rgb)
        c = line.cursor_from(x0)  # inherit bold/italic/decoration
        if c.bg == bg:
            continue  # already painted -> idempotent, no dirty churn
        lum = (
            0.2126 * (rgb >> 16) + 0.7152 * ((rgb >> 8) & 0xFF) + 0.0722 * (rgb & 0xFF)
        )
        c.bg = bg
        c.fg = as_rgb(0x000000 if lum > LUMA_SPLIT else 0xFFFFFF)
        c.reverse = False
        line.apply_cursor(c, x0, x1 - x0)
        changed += 1
    return changed


def paint_line(line: Any, cols: int) -> int:
    # str(line) is one C call, the cell walk is `cols` of them, so scan the
    # cheap text first: its offsets can be wrong, but its CONTENT cannot miss
    # a literal.
    text = str(line)
    spans = find_spans(text)
    if not spans:
        return 0
    # In a plain ASCII, tab-free line one char is one cell -- unless it holds
    # scaled/multicell text, which str(line) reports narrower than it renders.
    # Verifying the cells against the token catches exactly that. Only the
    # last span needs checking: the two drift sources that can go negative
    # (combining chars, tabs) are both non-ASCII or excluded above, so within
    # the fast path drift is non-negative and never shrinks left to right --
    # zero at the rightmost token means zero everywhere. The first span is
    # checked too, so a token that merely repeats along the line cannot make a
    # shifted match look clean.
    if text.isascii() and "\t" not in text:
        probes = (spans[-1],) if len(spans) == 1 else (spans[0], spans[-1])
        if all(cells_spell(line, s, text[s:e], cols) for s, e, _ in probes):
            return paint_spans(line, spans, None)
    text, cmap = text_and_cellmap(line, cols)
    return paint_spans(line, find_spans(text), cmap)


def paint_window(window: Any) -> int:
    screen = window.screen
    cols = screen.columns
    changed = 0
    for y in range(screen.lines):
        changed += paint_line(screen.line(y), cols)
    return changed


def windows_to_paint(boss: Boss) -> Any:
    if SCOPE == "all":
        yield from boss.all_windows
        return
    if SCOPE == "active":
        w = boss.active_window
        if w is not None:
            yield w
        return
    for tm in boss.os_window_map.values():
        tab = tm.active_tab
        if tab is None:
            continue
        for w in tab:
            if getattr(w, "is_visible_in_layout", True):
                yield w


def make_tick(boss: Boss) -> Any:
    # kitty calls a timer callback as callback(timer_id) (see
    # python_timer_callback in kitty/child-monitor.c), so the parameter has to
    # exist even though nothing here wants it: without it every tick raises
    # TypeError and nothing is ever painted. It is named with a leading
    # underscore so type checkers do not report it as unaccessed -- DELETING it
    # to silence that report breaks the watcher.
    def tick(_timer_id: int | None = None) -> None:
        for w in windows_to_paint(boss):
            try:
                if paint_window(w):
                    w.refresh()  # mark_as_dirty + wake io/main loops
            except Exception as e:  # noqa: BLE001
                logger.error(e)

    return tick


# kitty calls this as on_load(boss, {}) (see load_watchers in kitty/launch.py),
# so the second parameter has to exist even though nothing here wants it:
# without it the call raises TypeError, the timer is never installed, and the
# watcher is silently inert -- kitty logs that and carries on, so the only
# symptom is that nothing is ever coloured. Named with a leading underscore so
# type checkers do not report it as unaccessed; DELETING it is not a fix.
def on_load(boss: Boss, _data: dict[str, object]) -> None:
    if add_timer is not None:
        add_timer(make_tick(boss), INTERVAL, True)
