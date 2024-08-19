#!/usr/bin/env zsh

# peco

[[ -n $ZSH_DEBUG ]] && STARTTIME="$(($(gdate +%s%N)/1000000))"
# -----------------------------------------------------------------------------
# peco-select-history
#   - Adapted from: https://github.com/mooz/percol#zsh-history-search
#   - https://gist.github.com/jimeh/7d94f1000cfc9cba2893

function peco-select-history() {
  BUFFER=$(fc -l -n 1 | gtac | TERM=xterm-256color peco --query "$LBUFFER")
  CURSOR=$#BUFFER  # move cursor
  zle clear-screen # refresh
}
zle -N peco-select-history

# -----------------------------------------------------------------------------
# peco-ghq
# - http://weblog.bulknews.net/post/89635306479/ghq-peco-percol

function peco-ghq() {
  local selected=$(GIT_CONFIG=$XDG_CONFIG_HOME/ghq/.gitconfig ghq list -p | sed "s;$HOME;~;" | peco)
  if [ -n "$selected" ]; then
    BUFFER="cd ${selected}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ghq

# -----------------------------------------------------------------------------
# peco-godoc
# - http://syohex.hatenablog.com/entry/20140620/1403257070

function peco-godoc() {
  local -a go_packages

  go_packages=("builtin")
  for dir in $GOROOT $(perl -wle 'print $_ for split q{:}, shift' $GOPATH)
  do
    pkgdir="$dir/pkg"
    if [ -d $pkgdir ]; then
      packages=$(find $pkgdir -name "*.a" -and -not -iwholename '*vendor*' -type f | perl -wlp -e "s{$pkgdir/(?:(?:obj|tool)/)?[^/]+/}{} and s{\\.a\$}{}")
      go_packages=($packages $go_packages)
    fi
  done

  if ! hash source-highlight > /dev/null 2>&1; then
    echo 'not found source-highlight command'
    return 1
  fi

  command godoc $(echo $go_packages | sort | uniq | TERM=xterm-256color peco) | source-highlight --failsafe -f esc --lang-def=godoc.lang --style-file=esc.style | less
}
zle -N peco-godoc

# -----------------------------------------------------------------------------
# peco-manpage
# - http://qiita.com/Linda_pp/items/9ff801aa6e00459217f7

function peco_man_list() {
  local parent dir file
  local paths=("${(s/:/)$(man -aw)}")

  for parent in $paths;
  do
    for dir in $(command ls -1 $parent);
    do
      local p="${parent}/${dir}"
      if [ -d "$p" ]; then
        IFS=$'\n' local lines=($(/bin/ls -1 "$p"))
        for file in $lines;
        do
          echo "${p}/${file}"
        done
      fi
    done
  done
}

function peco-man() {
  local selected=$(peco_man_list | TERM=xterm-256color peco --prompt 'man >')
  if [[ "$selected" != "" ]]; then
    BUFFER="man $selected"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-man

function peco-man-ja() {
  local selected=$(LANG=ja_JP.UTF-8 peco_man_list | TERM=xterm-256color peco --prompt 'man >')
  if [[ "$selected" != "" ]]; then
    BUFFER="LANG=ja_JP.UTF-8 man ${selected}"
    zle accept-line
    zle clear-screen
  fi
}
zle -N peco-man-ja

# -----------------------------------------------------------------------------
# peco-gcloud-configurations

function peco-gcloud-configurations() {
  local selected=$(gcloud config configurations list --verbosity=none --format="value(name)" 2>/dev/null | TERM=xterm-256color peco --query "$LBUFFER")
  if [ -n "$selected" ]; then
    eval "gcloud config configurations activate --verbosity=none ${selected} > /dev/null 2>&1"
    echo -e "Activated [$selected]."
    zle accept-line
  fi
}
zle -N peco-gcloud-configurations

# -----------------------------------------------------------------------------
# peco-kubectl-context
# - https://gist.github.com/superbrothers/701f88472520fe3b6a3924ebeb1e18e5

function peco-kube-context() {
  local selected=$(kubectl config view -o go-template --template='{{range .contexts}}{{.name}}{{"\n"}}{{end}}' | TERM=xterm-256color peco --query "$LBUFFER")
  if [ -n "$selected" ]; then
    eval "kubectl config use-context ${selected} > /dev/null 2>&1"
    echo -e "Switched to context \"$selected\"."
    zle accept-line
  fi
}
zle -N peco-kube-context

# -----------------------------------------------------------------------------
# peco-stern
# - https://twitter.com/deeeet/status/890430334696804352
# - https://gist.github.com/tcnksm/f8584aad69b862c9c0888dd48275bb26
# - https://gist.github.com/superbrothers/cdcc0c3fe7ea2dd3b23087de91ac3836

function peco-kube-stern() {
  local selected=$(kubectl get deployments,daemonsets,statefulset --no-headers | cut -d ' ' -f 1 | TERM=xterm-256color peco --query "$LBUFFER" | cut -d '/' -f 2)
  if [ -n "$selected" ]; then
    BUFFER="stern ${selected}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-kube-stern

# -----------------------------------------------------------------------------
# peco-ssh

function peco-ssh() {
  local SELECTED_HOST=$(awk 'tolower($1)=="host" {for (i=2; i<=NF; i++) {if ($i !~ "[*?]") {print $i}}}' ~/.ssh/config | grep -v '127.0.0.1' | sort | uniq | TERM=xterm-256color peco --query "$LBUFFER")
  if [ -n "$SELECTED_HOST" ]; then
    BUFFER="ssh ${SELECTED_HOST}"
    zle accept-line
  fi
  zle clear-screen # refresh
}
zle -N peco-ssh

# -----------------------------------------------------------------------------
[[ -n $ZSH_DEBUG ]] && ENDTIME="$(($(gdate +%s%N)/1000000))" && printf "loaded modules/peco.zsh: %14s\\n" $(($ENDTIME - $STARTTIME))
