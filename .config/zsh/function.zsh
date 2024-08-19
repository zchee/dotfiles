#!/usr/bin/env zsh

# https://wiki.archlinux.org/index.php/Color_output_in_console#Reading_from_stdin

pty() {
  zpty pty-${UID} ${1+$@}
  if [[ ! -t 1 ]];then
    setopt local_traps
    trap '' INT
  fi
  zpty -r pty-${UID}
  zpty -d pty-${UID}
}

ptyless() {
  pty $* | less
}

# https://qiita.com/yuyuchu3333/items/67630d597c7700a51b95
function zman() {
  PAGER="less -g -s '+/^ {1..15}"$1"'" man zshall
}

# Search for zsh terms
# http://qiita.com/mollifier/items/14bbea7503910300b3ba
zwman() {
  zman "^       $1"
}

# Search for zsh flags
zfman() {
  local w='^'
  w=${(r:8:)w}
  w="$w${(r:7:)1}|$w$1(\[.*\].*)|$w$1:.*:|$w$1/.*/.*"
  zman "$w"
}
