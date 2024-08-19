#!/usr/bin/env zsh

# Ignore add zhistory
# - ref: http://mollifier.hatenablog.com/entry/20090728/p1
[[ -n $ZSH_DEBUG ]] && STARTTIME="$(($(gdate +%s%N)/1000000))"
# ----------------------------------------------------------------------------

zshaddhistory() {
  local line=${1%%$'\n'}
  local cmd=${line%% *}

  [[ ${#line} -ge 5
  && ${cmd} != (	*)
  && ${cmd} != (:*)
  ]]
}

# ----------------------------------------------------------------------------
[[ -n $ZSH_DEBUG ]] && ENDTIME="$(($(gdate +%s%N)/1000000))" && printf "loaded history.zsh: %19s\\n" $(($ENDTIME - $STARTTIME))
