# -----------------------------------------------------------------------------
# key-bindings

zmodload zsh/terminfo

# Use human-friendly identifiers
typeset -gA key
key=(
  'Escape'       '\e'
  'Backspace'    "${terminfo[kbs]}"
  'Meta'         '\M-'
  'BackTab'      "$terminfo[kcbt]"
  'Insert'       "$terminfo[kich1]"
  'Delete'       "${terminfo[kdch1]}"
  'Home'         "$terminfo[khome]"
  'End'          "$terminfo[kend]"
  'PageUp'       "$terminfo[kpp]"
  'PageDown'     "$terminfo[knp]"
  'Up'           "${terminfo[kcuu1]}"
  'Down'         "${terminfo[kcud1]}"
  'Left'         "${terminfo[kcub1]}"
  'Right'        "${terminfo[kcuf1]}"
  'Control'      '\C-'
  'C-Up'         '^[[1;5A'
  'C-Down'       '^[[1;5B'
  'C-Right'      '^[[1;5C'
  'C-Left'       '^[[1;5D'
  'C-Up'         '^[[1;5A'
  'C-Down'       '^[[1;5B'
  'S-Up'         "^[[1;2A"
  'S-Down'       "^[[1;2B"
  'S-Right'      "^[[1;2C"
  'S-Left'       "^[[1;2D"
  'S-Tab'        "^[[1;2Z"
  'F1'           "$terminfo[kf1]"
  'F2'           "$terminfo[kf2]"
  'F3'           "$terminfo[kf3]"
  'F4'           "$terminfo[kf4]"
  'F5'           "$terminfo[kf5]"
  'F6'           "$terminfo[kf6]"
  'F7'           "$terminfo[kf7]"
  'F8'           "$terminfo[kf8]"
  'F9'           "$terminfo[kf9]"
  'F10'          "$terminfo[kf10]"
  'F11'          "$terminfo[kf11]"
  'F12'          "$terminfo[kf12]"
)
  # 'Up'           "^[[A"
  # 'Down'         "^[[B"
  # 'Right'        "^[[C"
  # 'Left'         "^[[D"

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search history-search-end edit-command-line
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
zle -N edit-command-line

bindkey -e                                                      # use emacs key bindings
bindkey "$key[BackTab]"   reverse-menu-complete                 # move through the completion menu backwards
bindkey "$key[Backspace]" backward-delete-char                  # delete backward
bindkey "$key[Delete]"    delete-char                           # delete forward
bindkey "$key[Up]"        history-beginning-search-backward-end # first calling the corresponding builtin widget and then moving the cursor to the end of the line. 
bindkey "$key[Down]"      history-beginning-search-forward-end  # first calling the corresponding builtin widget and then moving the cursor to the end of the line. 
bindkey "$key[C-Up]"      forward-word                          # move forward one word
bindkey "$key[C-Down]"    backward-word                         # move backward one word
bindkey "$key[C-Right]"   forward-word                          # move forward one word
bindkey "$key[C-Left]"    backward-word                         # move backward one word
bindkey "$key[S-Right]"   forward-word                          # move forward one word
bindkey "$key[S-Left]"    backward-word                         # move backward one word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }

  function zle-line-finish() {
    echoti rmkx
  }

  zle -N zle-line-init
  zle -N zle-line-finish
fi

function sk-select-history() {
  BUFFER=$(fc -l -n 1 | "${prefix}/opt/coreutils/libexec/gnubin/tac" | sk --ansi -m --bind 'ctrl-d:page-down,ctrl-u:page-up' --layout=reverse --regex --algo=skim_v2 --no-sort --query "$LBUFFER")
  CURSOR=$#BUFFER  # move cursor
  zle clear-screen # refresh
}
zle -N sk-select-history

function sk-ghq() {
  local selected=$(GIT_CONFIG=~/.config/ghq/.gitconfig GOGC=off ghq list -p | sk --ansi -m --bind 'ctrl-d:page-down,ctrl-u:page-up' --layout=reverse --regex --algo=skim_v2 --no-sort)
  if [ -n "$selected" ]; then
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N sk-ghq

bindkey "^I"                   complete-word
bindkey "^[m"                  copy-prev-shell-word                 # file rename magic
bindkey '^[[1;^D'              kill-word
bindkey '^F'                   zle_ctrlz
# bindkey '^Q'                   sk-ghq
bindkey '^Q'                   peco-ghq
# bindkey '^R'                   sk-select-history
bindkey '^R'                   peco-select-history
bindkey '^S'                   zle_sticky_set
bindkey '^Z^r'                 history-incremental-search-backward  # replace from '^r'
# bindkey '^Zd'                  peco-godoc #
bindkey '^Zf'                  edit-command-line
bindkey '^Zgc'                 peco-gcloud-configurations
bindkey '^Zkc'                 peco-kube-context
bindkey '^Zks'                 peco-kube-stern
# bindkey '^Zm'                  peco-man #
bindkey '^Zs'                  peco-ssh
# bindkey '^Zt'                  peco-tmux-buffer #

# -----------------------------------------------------------------------------
# zleiab
#
# vim like abbreviation
# zshwiki.org: https://web.archive.org/web/20180706090057/https://zshwiki.org/home/examples/zleiab
#

setopt EXTENDED_GLOB

typeset -Ag abbreviations
abbreviations=(
  "A"    "| awk"
  "ANR"  "| awk 'NR>1{print \$0}'"
  "B"    "| bat -"
  "D"    "--debug"
  "G"    "| grep"
  "H"    "| pt"
  "J"    "| jq ."
  "L"    "| less"
  "N"    "> /dev/null 2>&1"
  "OJ"   "-o json | bat -l json -"
  "OY"   "-o yaml | bat -l yaml -"
  "P"    "| pbcopy"
  "S"    "| sort"
  "SB"   "--sort-by '.metadata.creationTimestamp'"
  "SV"   "| sort --version-sort"
  "T"    "| tail"
  "V"    "V=1"
  "W"    "| wc -l"
  "X"    "| xargs"
  "XC"   "| xcpretty --color -r json-compilation-database -o compile_commands.json"
)

function magic-abbrev-expand() {
  local MATCH
  LBUFFER=${LBUFFER%%(#m)[-_a-zA-Z0-9]#}
  if [ -n $LBUFFER ]; then
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
    zle self-insert
  fi
}

function no-magic-abbrev-expand() {
  LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
bindkey " " magic-abbrev-expand
bindkey "^x " no-magic-abbrev-expand

# shellcheck disable=SC2190
