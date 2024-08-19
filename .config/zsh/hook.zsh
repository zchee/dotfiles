#!/usr/bin/env zsh

# -----------------------------------------------------------------------------
# hook (add-zsh-hook)

[[ -n $ZSH_DEBUG ]] && STARTTIME="$(($(gdate +%s%N)/1000000))"

# -----------------------------------------------------------------------------
# autoload add-zsh-hook

autoload -Uz add-zsh-hook

# order of fire the hook
typeset -ag chpwd_functions
typeset -ag periodic_functions
typeset -ag preexec_functions
typeset -ag precmd_functions

# -----------------------------------------------------------------------------
# ls_abbrev
#
# Change directory with auto ls
#  -A : Do not show . and ..
#  -C : Force multi-column output.
#  -F : Append indicator (one of */=>@|) to entries.

function _ls_abbrev() {
  if hash gls > /dev/null 2>&1; then
    local cmd_ls='gls'
  else
    local cmd_ls='ls'
  fi
  local -a opt_ls
  opt_ls=(
    '-ACF'
    '--group-directories-first'
    '--color=always'
    '--ignore=.DS_Store'
    '--ignore=.localized'
    '--ignore=__pycache__'
    '--ignore=.mypy_cache'
    '--ignore=.idea'
    '--ignore=.vscode'
    '--ignore=.idea'
  )

  local ls_result
  ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

  local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

  if [ $ls_lines -gt 10 ]; then
    echo "$ls_result\n" | head -n 5
    echo '...'
    echo "$ls_result\n" | tail -n 5
    echo "$(command $cmd_ls -1 -A | wc -l | tr -d ' ') files exist"
  else
    echo "$ls_result\n"
  fi
}

if [[ -z "${chpwd_functions[(r)_ls_abbrev]+1}" ]]; then
  chpwd_functions=( ${chpwd_functions[@]} _ls_abbrev )
fi

# -----------------------------------------------------------------------------
# hooks

_direnv_hook() {
  trap -- '' SIGINT
  eval "$("/usr/local/bin/direnv" export zsh)"
  trap - SIGINT
}
typeset -ag precmd_functions
if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
  precmd_functions=($precmd_functions _direnv_hook)
fi
typeset -ag chpwd_functions
if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
  chpwd_functions=($chpwd_functions _direnv_hook)
fi

# -----------------------------------------------------------------------------
# history 
# - http://someneat.hatenablog.jp/entry/2017/07/25/073428

# _record_command() {
#   typeset -g _LASTCMD=${1%%$'\n'}
#   return 1
# }
# zshaddhistory_functions+=(_record_command)

# _update_history() {
#   local last_status="$?"
#
#   local HISTFILE=~/.zsh_history
#   fc -W
#   if [[ ${last_status} -ne 0 ]]; then
#     ed -s ${HISTFILE} <<EOF >/dev/null
# d
# w
# q
# EOF
#   fi
# }
# precmd_functions+=(_update_history)

# __update_history() {
#   local last_status="$?"
#
#   # hist_ignore_space
#   if [[ ! -n ${_LASTCMD%% *} ]]; then
#     return
#   fi
#
#   # hist_reduce_blanks
#   local cmd_reduce_blanks=$(echo ${_LASTCMD} | tr -s ' ')
#
#   # Record the commands that have succeeded
#   if [[ ${last_status} == 0 ]]; then
#     print -sr -- "${cmd_reduce_blanks}"
#   fi
# }
# precmd_functions+=(__update_history)

# -----------------------------------------------------------------------------
[[ -n $ZSH_DEBUG ]] && ENDTIME="$(($(gdate +%s%N)/1000000))" && printf "loaded $(basename $0): %22s\\n" $(($ENDTIME - $STARTTIME))
