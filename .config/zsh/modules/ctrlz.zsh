#!/usr/bin/env zsh

# -----------------------------------------------------------------------------
# zle
#
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

[[ -n $ZSH_DEBUG ]] && STARTTIME="$(($(gdate +%s%N)/1000000))"
# -----------------------------------------------------------------------------

function zle_ctrlz() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N zle_ctrlz

# -----------------------------------------------------------------------------
[[ -n $ZSH_DEBUG ]] && ENDTIME="$(($(gdate +%s%N)/1000000))" && printf "loaded zle.zsh: %23s\\n" $(($ENDTIME - $STARTTIME))
