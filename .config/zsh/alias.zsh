#!/usr/bin/env zsh

# -----------------------------------------------------------------------------
# aliases

[[ -n $ZSH_DEBUG ]] && STARTTIME="$(($(gdate +%s%N)/1000000))"
# -----------------------------------------------------------------------------
# nocorrect, noglob

# disable correction
alias cp='nocorrect cp'
alias ebuild='nocorrect ebuild'
alias gcc='nocorrect gcc'
alias grep='nocorrect grep'
alias ln='nocorrect ln'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias rm='nocorrect rm'

# disable globbing
alias fc='noglob fc'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'
alias zmv='noglob zmv -W'

if [[ -d "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
  alias printf="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin/printf"
else
  alias printf='/usr/bin/printf'
fi

# -----------------------------------------------------------------------------
# general

alias _='sudo'
alias cp="${aliases[cp]:-cp} -i"
# alias b='${(z)BROWSER}'
# alias e='${(z)VISUAL:-${(z)EDITOR}}'

# will safety
alias ln="${aliases[ln]:-ln} -i"
alias mkdir="${aliases[mkdir]:-mkdir} -p"
alias mv="${aliases[mv]:-mv} -i"
alias rm="${aliases[rm]:-rm} -i"

alias sortv='gsort --version-sort'

# -----------------------------------------------------------------------------
# zsh profiling

alias zstartuptime='time ( ZSH_DEBUG=1 zsh -i -c exit )'

# -----------------------------------------------------------------------------
# Shell builtin

alias j='jobs'

## Platform specific

case $OSTYPE in
  (darwin*)
    alias say='say --quality=127'  # use top of high quality
    alias flush='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'  # Flush Directory Service cache
    alias plistbuddy="/usr/libexec/PlistBuddy"  # alter defaults command
    alias o='open'  # short type open
    alias pbc="awk -v ORS="" '1' | pbcopy"  # shorthand pasteboard command
    alias pbp='pbpaste'  # shorthand pasteboard command
    alias clean-ds_store='fd --no-ignore-vcs .DS_Store --exec rm -rf {}'
    ;;

  (linux*)
    alias o='xdg-open'  # short type open
    if (( $+commands[xclip] )); then
      alias pbcopy='xclip -selection clipboard -in'
      alias pbpaste='xclip -selection clipboard -out'
    elif (( $+commands[xsel] )); then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
    ;;
esac

# -----------------------------------------------------------------------------
# override

# -----------------------------------------------------------------------------
# Unix command

## ls

# gls:
#  -A: do not list implied . and ..
#  -F: append indicator (one of */=>@|) to entries
#  -l: with -l and -s, print sizes like 1K 234M 2G etc
#  -h: use a long listing format
#  -R: list subdirectories recursively
#  -X: sort alphabetically by entry extension
#  -B: do not list implied entries ending with ~
#  -S: sort by file size, largest first
#  -r: reverse order while sorting
#  -t: sort by modification time, newest first
#  -c: with -lt: sort by, and show, ctime; with -l: show ctime and sort by name; otherwise: sort by ctime, newest first
#  -u: with -lt: sort by, and show, access time; with -l: show access time and sort by name; otherwise: sort by access time, newest first
#  -d: list directories themselves, not their contents

if (( $+commands[gls] )); then
  alias ls='gls --group-directories-first --color=auto --ignore={.DS_Store,.localized,._UG\#_Store}'

  alias  l='ls -AF'                          # Lists hidden files, indicator
  alias ll='ls -hlF'                         # Lists human readable sizes, show indicator
  alias l.='ls -ld .[a-zA-Z]*'               # Lists dotfiles only
  alias la='ls -lhAF'                        # Lists human readable sizes, show indicator, hidden files and inode
  alias lr='ls -R'                           # Lists human readable sizes, show indicator with recursively
  alias lm='la | "$PAGER"'                   # Lists human readable sizes, show indicator and hidden files through pager
  alias lx='ls -lhBFX'                       # Lists sorted by extension (GNU only)
  alias lk='ls -lhrFS'                       # Lists sorted by size, largest last
  alias lt='ls -ahlrtF'                      # Lists sorted by date, most recent last
  alias lc='lt -c'                           # Lists sorted by date, most recent last, shows change time
  alias lu='lt -u'                           # Lists sorted by date, most recent last, shows access time
  alias sl='ls'                              # I often screw this up
  alias al='la'                              # wtf
else
  # TODO(zchee): support darwin default ls flag
  alias ls='ls'
fi

alias eza='eza -Al --group-directories-first'

## grep

if (( $+commands[ggrep] )); then
  alias grep="ggrep --color=auto"
else
  alias grep="grep --color=auto"
fi

alias fd='fd --follow --hidden --exclude=.git'

## watch
alias watchx='watch -n 1 -t -c -x -w'

## df: resource usage
alias df='df -kh'
alias du='du -kh'
alias dirsize='du -h --max-depth=0'

## build

alias bearmake='bear --force-preload --force-wrapper -- make'

## base64-enc: base64 encoding without wrap
if (( $+commands[gbase64] )); then
  alias base64-enc='gbase64 --wrap=0'
else
  alias base64-enc='/usr/bin/base64 --break=0'
fi

## git

alias g='git'
alias gs='git s'
alias gc='git c'
alias grt='cd $(git rev-parse --show-toplevel)'
alias gdiff='git diff --no-index --indent-heuristic --minimal'

# http://qiita.com/tarr1124/items/d807887418671adbc46f
gfp() {
  USER_BRANCH=$2
  USER_BRANCH=(${(s/:/)USER_BRANCH})
  git fetch origin pull/"$1"/head:"$USER_BRANCH[2]"
  git branch --move $USER_BRANCH[2] pull/"$1"/"$USER_BRANCH[1]"/"$USER_BRANCH[2]"
  unset USER_BRANCH
}

# -----------------------------------------------------------------------------
# Command

[ -d "${prefix}/opt/universal-ctags" ] && alias ctags="${prefix}/opt/universal-ctags/bin/ctags"

## gcloud
alias gcl='gcloud'
## compute ssh
alias gcloud-ssh='TERM=xterm-256color gcloud compute ssh --tunnel-through-iap --verbosity=none'
alias gcloud-scp='TERM=xterm-256color gcloud compute scp --tunnel-through-iap --verbosity=none'
### spanner
alias spanner-emulator="docker container run --rm --name spanner-emulator -p 127.0.0.1:9010:9010 -p 127.0.0.1:9020:9020 -e GRPC_GO_LOG_SEVERITY_LEVEL=INFO -e GRPC_GO_LOG_VERBOSITY_LEVEL=99 gcr.io/cloud-spanner-emulator/emulator:latest ./gateway_main -copy_emulator_stderr -copy_emulator_stdout -hostname 0.0.0.0 -log_requests"
alias spanner-sql="gcloud --project=$GCP_PROJECT_ID alpha spanner databases execute-sql --instance=$SPANNER_INSTANCE_ID $SPANNER_DATABASE_NAME"
### Slow queries
alias spanner-slow_query_hour="gcloud --project=$GCP_PROJECT_ID alpha spanner databases execute-sql --sql='SELECT * FROM SPANNER_SYS.QUERY_STATS_TOP_HOUR' --instance=$SPANNER_INSTANCE_ID $SPANNER_DATABASE_NAME"
alias spanner-slow_query_min="gcloud --project=$GCP_PROJECT_ID alpha spanner databases execute-sql --sql='SELECT * FROM SPANNER_SYS.QUERY_STATS_TOP_MINUTE' --instance=$SPANNER_INSTANCE_ID $SPANNER_DATABASE_NAME"
alias spanner-slow_query_10min="gcloud --project=$GCP_PROJECT_ID alpha spanner databases execute-sql --sql='SELECT * FROM SPANNER_SYS.QUERY_STATS_TOP_10MINUTE' --instance=$SPANNER_INSTANCE_ID $SPANNER_DATABASE_NAME"

## Kubernetes
alias k='kubectl'
alias kk="KUBECONFIG=$XDG_CONFIG_HOME/kube/kind kubectl"
alias wk='watch -n 1 -t -x kubectl'

## terraform
alias tf='terraform'

## cilium/hubble
alias hubble="kubectl exec -it -n gke-managed-dpv2-observability deployment/hubble-relay -c hubble-cli -- hubble"

## argo
alias argocd='argocd --grpc-web'

## lima
alias apko='LIMA_INSTANCE=apko lima apko'

alias t='tig'
alias tm='git fetch --all --prune --tags --force --quiet; tig $(git rev-parse --abbrev-ref HEAD)..$(git rev-parse --abbrev-ref origin)'

alias nvim-startuptime='nvim --startuptime /tmp/nvim-startuptime'

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

alias pping='prettyping'

# -----------------------------------------------------------------------------
# Languages

## Go
alias gobench="sync; sudo purge; go test -v -run='^$' -benchmem $*"
alias goprofile="go test -c $1 && ./*.test -test.run='^$' -test.bench=. -test.cpuprofile=cpu.prof -test.memprofile=mem.prof && go tool pprof *.test cpu.prof mem.prof"  # https://twitter.com/davecheney/status/175826483191885825
alias go-nullbuild="go build -v -x -o /dev/null $*"
alias go-checkptr="go test -v -count 1 -gcflags='all=-d=checkptr=1' $*"
alias go-ssa-check-bce="go build -o /dev/null -gcflags='-d=ssa/check_bce/debug=3' $*"  # https://github.com/golang/go/blob/go1.16beta1/test/checkbce.go#L2
alias go-ssa-prove="go build -o /dev/null -gcflags='-d=ssa/prove/debug=1' $*"  # https://github.com/golang/go/blob/go1.16beta1/test/prove.go#L2
alias go-opt-analysis="go build -o /dev/null -gcflags='-m=1' $*"
alias go-opt-analysis-deep="go build -o /dev/null -gcflags='-m=5 $*'"

## C/C++
alias root='root -l' # disable root splash by default

## Rust

## Python
alias intelpyton3='TERM=xterm-256color /opt/intel/oneapi/intelpython/latest/bin/python'
alias intelpyton3-pip='intelpyton3 -m pip'
alias mamba='micromamba'

## Nodejs

## Lua
# alias luamake=/Users/zchee/.local/share/nvim/lspinstall/lua/lua-language-server/3rd/luamake/luamake
alias luarocks-5.3="LUAROCKS_CONFIG=$XDG_CONFIG_HOME/lua/luarocks/config-5.3.lua luarocks --lua-dir=${prefix}/opt/lua@5.3"

## Ruby
# alias rbenv="RUBY_CONFIGURE_OPTS='--with-openssl-dir=${prefix}/opt/openssl --disable-dtrace' rbenv"
# alias rbenv="MAKE_OPTS='-j32' RUBY_CFLAGS='-Wno-compound-token-split-by-macro' RUBY_CONFIGURE_OPTS='--with-openssl-dir=${prefix}/opt/openssl@3 --disable-dtrace' rbenv"
alias rbenv="MAKE_OPTS='-j32' RUBY_CFLAGS='-Wno-compound-token-split-by-macro' RUBY_CONFIGURE_OPTS='--with-openssl-dir=${prefix}/opt/openssl@1.1 --disable-dtrace' rbenv"

## Java
# alias gradle='TERM=xterm-256color gradle'

## zsh
### theme
alias pure='autoload -Uz promptinit; promptinit && prompt pure'
alias blax='autoload -Uz promptinit; promptinit && prompt blax'

# -----------------------------------------------------------------------------
# misc

alias brew='TERM=xterm-256color brew'
alias get='ghq get -u --no-recursive'
alias pbpath='echo -n `pwd` | /usr/bin/pbcopy'
alias atoz="( echo ' '{a..z} && printf '%2s ' {0..25} )"

# -----------------------------------------------------------------------------
[[ -n $ZSH_DEBUG ]] && ENDTIME="$(($(gdate +%s%N)/1000000))" && printf "loaded alias.zsh: %21s\\n" $(($ENDTIME - $STARTTIME))
