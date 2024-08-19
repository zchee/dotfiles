# -----------------------------------------------------------------------------
# Zsh config

# zsh modules
# https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html
zmodload \
  'zsh/attr' \
  'zsh/cap' \
  'zsh/clone' \
  'zsh/compctl' \
  'zsh/complete' \
  'zsh/complist' \
  'zsh/computil' \
  'zsh/curses' \
  'zsh/datetime' \
  'zsh/db/gdbm' \
  'zsh/deltochar' \
  'zsh/files' \
  'zsh/mapfile' \
  'zsh/mathfunc' \
  'zsh/parameter' \
  'zsh/parameter' \
  'zsh/pcre' \
  'zsh/param/private' \
  'zsh/regex' \
  'zsh/sched' \
  'zsh/net/socket' \
  'zsh/stat' \
  'zsh/system' \
  'zsh/net/tcp' \
  'zsh/termcap' \
  'zsh/terminfo' \
  'zsh/zle' \
  'zsh/zleparameter' \
  'zsh/zpty' \
  'zsh/zselect' \
  'zsh/zutil'

disable functions chmod
# disable functions printf
# disable -r time
# disable log  # Disable the log builtin, so we don't conflict with /usr/bin/log
# disable ulimit

REPORTTIME=50
WORDCHARS='*?_-.[]~&;!#$%^{}<>'  # default: '*?_-.[]~=/&;!#$%^(){}<>', remove '()' for such as "gcloud --format='value(...[C-w])'"
HISTFILE="${HOME}/.history/zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

# The Z Shell Manual - Options
#  - http://zsh.sourceforge.net/Doc/Release/Options.html#Options
setopt   ALWAYS_LAST_PROMPT       # Keep cursor on completion
setopt   ALWAYS_TO_END            # Move cursor to the end of a completed word
setopt   ALIASFUNCDEF
setopt   AUTO_CD                  # Auto changes to a directory without typing cd.
setopt   AUTO_LIST                # Automatically list choices on ambiguous completion
setopt   AUTO_MENU                # Show completion menu on a successive tab press
setopt   AUTO_NAME_DIRS           # Auto add variable-stored paths to ~ list.
setopt   AUTO_PUSHD               # Push the old directory onto the stack on cd.
setopt   BANG_HIST                # Treat the '!' character specially during expansion
setopt   CDABLE_VARS              # Change directory to a path stored in a variable.
setopt   COMBINING_CHARS          # Correctly display UTF-8 with combining characters.
setopt   COMPLETE_IN_WORD         # Complete from both ends of a word
setopt   EXTENDED_GLOB            # Use extended globbing syntax.
setopt   EXTENDED_HISTORY         # Write the history file in the ':start:elapsed;command' format
setopt   GLOBDOTS                 # Show dotfiles on completion
setopt   HIST_EXPAND              # Expand automatically history to completion
setopt   HIST_EXPIRE_DUPS_FIRST   # Expire a duplicate event first when trimming history
setopt   HIST_FIND_NO_DUPS        # Do not display a previously found event
setopt   HIST_IGNORE_ALL_DUPS     # Delete an old recorded event if a new event is a duplicate
setopt   HIST_IGNORE_DUPS         # Do not record an event that was just recorded again
setopt   HIST_IGNORE_SPACE        # Do not record an event starting with a space
setopt   HIST_REDUCE_BLANKS       # Remove extra blanks from each command line being added to history
setopt   HIST_SAVE_NO_DUPS        # Do not write a duplicate event to the history file
setopt   HIST_VERIFY              # Do not execute immediately upon history expansion
setopt   IGNOREEOF                # Disable '^D' logout keybind
setopt   INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits
setopt   LIST_PACKED              # trim grouping list spaces
setopt   LIST_TYPES               # Marking file info on completion list
setopt   LONG_LIST_JOBS           # List jobs in the long format by default.
setopt   MAGIC_EQUAL_SUBST        # Enable show prefix = in completions
setopt   MARK_DIRS                # Auto completion on folder end slash
setopt   MENU_COMPLETE            # Autoselect the first completion entry
setopt   MULTIOS                  # Write to multiple descriptors.
setopt   PATH_DIRS                # Perform path search even on command names with slashes
setopt   PUSHD_IGNORE_DUPS        # Do not store duplicates in the stack.
setopt   PUSHD_SILENT             # Do not print the directory stack after pushd or popd.
setopt   PUSHD_TO_HOME            # Push to home directory when no argument is given.
setopt   SHARE_HISTORY            # Share history between all sessions

unsetopt AUTO_PARAM_SLASH         # If completed parameter is a directory, add a trailing slash
unsetopt CLOBBER                  # Do not overwrite existing files with > and >>. Use >! and >>! to bypass.
unsetopt CORRECT                  # Disable zsh correct
unsetopt FLOW_CONTROL             # Disable start/stop characters in shell editor

# -----------------------------------------------------------------------------
# Functions:

# Load the all function script under the ${HOME}/.zsh/functions
# (:t) is strip directory name, print only filename
# Initialize the commnad completions.
#  -C: disable security check
# http://zsh.sourceforge.net/Doc/Release/Expansion.html#Modifiers
autoload -Uz \
  zmv \
  ${XDG_CONFIG_HOME}/zsh/functions/*(:t)

# -----------------------------------------------------------------------------
# prompt

PURE_CMD_MAX_EXEC_TIME=10

autoload -Uz promptinit
promptinit && prompt pure  # prompt zpt, pure

# -----------------------------------------------------------------------------
# Load plugins

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern root line regexp)  # available: main brackets pattern cursor root line regexp
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=green,bold"
ZSH_HIGHLIGHT_STYLES[alias]='bg=blue,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='bg=blue'
ZSH_HIGHLIGHT_STYLES[function]='bg=blue'
ZSH_HIGHLIGHT_STYLES[command]='bg=blue'
ZSH_HIGHLIGHT_STYLES[precommand]='bg=blue,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='none'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=cyan,bold' # none, fg=037
ZSH_HIGHLIGHT_STYLES[autodirectory]='none,underline' # none, fg=166?
ZSH_HIGHLIGHT_STYLES[path]='none,underline' # none, fg=166?
ZSH_HIGHLIGHT_STYLES[globbing]='fg=blue' # none
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=white,underline' # fg=blue
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=none' # 125?
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=none' # 125?
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='none'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow' # fg=136?
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow' # fg=136?
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan' # fg=cyan?, fg=136
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=cyan' # fg=cyan?, fg=136
ZSH_HIGHLIGHT_STYLES[comment]='fg=white'
ZSH_HIGHLIGHT_STYLES[assign]='bg=blue' # same as command

# bracket
## bracket-error           -  unmatched brackets
## bracket-level-N         -  brackets with nest level N
## cursor-matchingbracket  -  the matching bracket, if cursor is on a bracket
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=magenta,bold'

## pattern
# typeset -A ZSH_HIGHLIGHT_PATTERNS
# ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bg=red')

# cursor
## cursor - the style for the current cursor position

# line
## line - the style for the whole line

# root
## root - the style for the whole line if the current user is root.

# -----------------------------------------------------------------------------
# Load local modules

source ${XDG_CONFIG_HOME}/zsh/modules/zsh-defer.plugin.zsh

for f in ${XDG_CONFIG_HOME}/zsh{/,/modules/}*.zsh
do
  source $f
done

if [[ -d "${prefix}/opt/zsh-syntax-highlighting" ]]; then
  # TODO(zchee): use zsh-defer
   zsh-defer source "${prefix}/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/usr/local/opt/micromamba/bin/micromamba';
export MAMBA_ROOT_PREFIX='/usr/local/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

if [[ -n $ZPROFILE ]]; then zprof; fi
