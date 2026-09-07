"""kitty watcher: repaint every #RRGGBB token on screen with its own colour.

    kitty.conf:  watcher /path/to/hex_colorizer.py

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

try:
    from kitty.fast_data_types import add_timer
except ImportError:  # pragma: no cover - only missing outside a kitty process
    add_timer = None

HEX = re.compile(r"#([0-9a-fA-F]{6})(?![0-9a-fA-F])")
INTERVAL = 0.016  # s, one tick per 60Hz frame
LUMA_SPLIT = 140.0
SCOPE = "visible"  # 'visible' | 'active' | 'all'

logger = logging.getLogger(__name__)


def as_rgb(x: int) -> int:
    return (x << 8) | 2


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


def paint_line(line: Any, cols: int) -> int:
    # Cheap pre-filter: str(line) is one C call, the cell walk is `cols` of
    # them. Offsets from str(line) can be wrong, but its CONTENT cannot miss
    # a '#'.
    text = str(line)
    if "#" not in text:
        return 0
    fast = text.isascii() and "\t" not in text
    cmap: Any = range(cols + len(text)) if fast else None
    if cmap is None:
        text, cmap = text_and_cellmap(line, cols)
    changed = 0
    for m in HEX.finditer(text):
        x0 = cmap[m.start()]
        if fast and (x0 >= cols or line[x0] != "#"):
            # Offsets drifted after all (scaled/multicell ASCII text) -- redo
            # this line against the real cells.
            return paint_line_slow(line, cols)
        rgb = int(m.group(1), 16)
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
        x1 = cmap[m.end() - 1] + 1
        line.apply_cursor(c, x0, x1 - x0)
        changed += 1
    return changed


def paint_line_slow(line: Any, cols: int) -> int:
    text, cmap = text_and_cellmap(line, cols)
    changed = 0
    for m in HEX.finditer(text):
        rgb = int(m.group(1), 16)
        bg = as_rgb(rgb)
        x0 = cmap[m.start()]
        c = line.cursor_from(x0)
        if c.bg == bg:
            continue
        lum = (
            0.2126 * (rgb >> 16) + 0.7152 * ((rgb >> 8) & 0xFF) + 0.0722 * (rgb & 0xFF)
        )
        c.bg = bg
        c.fg = as_rgb(0x000000 if lum > LUMA_SPLIT else 0xFFFFFF)
        c.reverse = False
        x1 = cmap[m.end() - 1] + 1
        line.apply_cursor(c, x0, x1 - x0)
        changed += 1
    return changed


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
    def tick() -> None:
        for w in windows_to_paint(boss):
            try:
                if paint_window(w):
                    w.refresh()  # mark_as_dirty + wake io/main loops
            except Exception as e:  # noqa: BLE001
                logger.error(e)

    return tick


def on_load(boss: Boss) -> None:
    if add_timer is not None:
        add_timer(make_tick(boss), INTERVAL, True)
