#!/usr/bin/env zsh

# zsh-sticky-prefix
# https://github.com/utdemir/me/blob/master/blog/zsh-sticky-prefix.md

local zle_sticked=""

function zle_sticky_line_init() {
  BUFFER="$zle_sticked$BUFFER"
  zle end-of-line
}
zle -N zle_sticky_line_init

function zle_sticky_accept_line() {
  if [[ -z "$BUFFER" ]] && [[ -n "$zle_sticked" ]]; then
    zle_sticked=""
  fi
  zle .accept-line
}
zle -N zle_sticky_accept_line

function zle_sticky_set() {
  zle_sticked="$BUFFER"
  zle -M "sticky: '$zle_sticked'."
}
zle -N zle_sticky_set
