# -----------------------------------------------------------------------------
# completion
# - https://github.com/seebi/zshrc/blob/master/completion.zsh
# ----------------------------------------------------------------------------
# zstyle comletion

unsetopt CASE_GLOB

# group matches and describe format
zstyle ':completion:*'  accept-exact '*(N)'
zstyle ':completion:*'  complete-options true
zstyle ':completion:*'  completer _complete _match _approximate
zstyle ':completion:*'  format ' %F{yellow}-- %d --%f'
zstyle ':completion:*'  group-name ''                            # for all completions: grouping the output
zstyle ':completion:*'  list-colors ${(s.:.)LS_COLORS} ma=0\;47  # for all completions: color
zstyle ':completion:*'  matcher-list 'm:{a-zA-Z}={A-Za-z}'       # 'm:{a-z}={A-Z}', case insensitivity 'r:|[._-]=* r:|=*' 'l:|=* r:|=*', 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'  # case-insensitive -> partial-word (cs) -> substring completion, 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*'  menu select=2                            # for all completions: menuselection ':completion:*:*:*:*:*'
zstyle ':completion:*'  path-completion true
zstyle ':completion:*'  rehash true                              # auto rehash commands http://www.zsh.org/mla/users/2011/msg00531.html
zstyle ':completion:*'  special-dirs false                       # completion of .. directories
zstyle ':completion:*'  verbose yes

zstyle ':completion:*:default'      list-prompt '%S%M matches%s'
zstyle ':completion:*:corrections'  format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:corrections'  format ' %F{green}-- %d --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:matches'      group 'yes'
zstyle ':completion:*:messages'     format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings'     format ' %F{red}-- no matches found --%f'

zstyle ':completion:*:options'          auto-description '%d'
zstyle ':completion:*:options'          description 'yes'

# caching coompletion results
zstyle ':completion::complete:*'        use-cache on
zstyle ':completion::complete:*'        cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# fuzzy match mistyped completions
zstyle ':completion:*:match:*'          original only
zstyle ':completion:*:approximate:*'    max-errors 1 numeric

# increase the number of errors based on the length of the typed word
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# don't complete unavailable commands
zstyle ':completion:*:functions'        ignored-patterns '(_*|pre(cmd|exec))'

# array completion element sorting
zstyle ':completion:*:*:-subscript-:*'  tag-order indexes parameters

# directories
zstyle ':completion:*:default'                list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*'                 tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*'                 ignored-patterns '(*/)#lost+found' parent pwd
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*'              group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*'                        squeeze-slashes true

# history
zstyle ':completion:*:history-words'    stop yes
zstyle ':completion:*:history-words'    remove-all-dups yes
zstyle ':completion:*:history-words'    list false
zstyle ':completion:*:history-words'    menu yes

# environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# ignore patterns
zstyle ':completion:*:*files' ignored-patterns \
  '.git' '.hg' '.svn' \
  '*.DS_Store' '*.localized' \
  '*?.aux' '*?.out' '*?.o' \
  '*?.zwc' \
  '__pycache__' '*?.mypy_cache' \
  '*.idea' '._UG\\#_Store'

# don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
  dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
  mailman mailnull mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# unless we really want to.
zstyle '*' single-ignored show

# ignore multiple entries
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# git
# ref: comment on /usr/local/share/zsh/functions/_git
zstyle ':completion:*:*:git:*'  user-commands fetch-parallel:'download objects and refs each repositories with GNU parallel'
zstyle ':completion:*:*:git:*'  user-commands gen:'Generate repository with boilarplates'
zstyle ':completion:*:*:git:*'  user-commands goget:'Get downloads the Go packages named by the import path'
zstyle ':completion:*:*:git:*'  user-commands list-gitignore:'List gitignore from github/gitignore repository'
zstyle ':completion:*:*:git:*'  user-commands ydiff:'Show diff by side split view'
zstyle ':completion:*:*:git*:*' use-fallback false


# kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# ssh/scp/rsync
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# docker
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# cmake
cmake_langs=('C' 'C' 'CXX' 'C++')
zstyle ':completion:*:cmake:*' languages $cmake_langs

# disable zsh vcs_info
zstyle ':vcs_info' disable

zstyle :compinstall filename '~/.zshrc'

# -----------------------------------------------------------------------------
# compdef

# autoload -Uz compdef complete compinit

autoload -Uz compdef complete compinit
_comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
if [[ "$_comp_path(#qNmh-20)" ]]; then
  compinit -i -C -d "$_comp_path"
else
  mkdir -p "$_comp_path:h"
  compinit -i -d "$_comp_path"
  touch "$_comp_path"
fi
unset _comp_path

# Go
compdef _go gotest
compdef _goimports gofumports

# rg for Go files and kubernetes packages
compdef _rg rgo krg

# docker
compdef _dep docker-dep
compdef _shellcheck docker-shellcheck

# lua
compdef _luarocks luarocks-luajit

# macOS builtin command
compdef _log log

# command
compdef _git tig
compdef _git t
compdef _nvim n               # neovim/neovim
compdef _ssh sshrc            # Russell91/sshrc
compdef _make ccache-make     # ccache/ccache
compdef _clang ccache-clang   # ccache/ccache
compdef _clang ccache-clang++ # ccache/ccache
compdef _cmake ccache-cmake   # ccache/ccache
compdef _bazel bazel          # bazelbuild/bazel
compdef _bazel bazelisk       # bazelbuild/bazelisk
compdef _terminals infocmp
compdef _op op-gaudiy

# zsh function
compdef _files mcd  # mkdir and cd shorthand
compdef _man jman   # jman
compdef _command_names find-completion  # completion
compdef _command_names edit-completion
compdef _command_names reload-completion

# https://github.com/eth-p/bat-extras
compdef _man batman

# _gnu_generic
compdef _gnu_generic \
  appcfg.py \
  autopep8 \
  bison \
  bulkload_client.py \
  bulkloader.py \
  ccache \
  cpulimit \
  ctags \
  docker-credential-gcloud \
  dot \
  download_appstats.py \
  dry \
  endpointscfg.py \
  flex \
  flex++ \
  fontforge \
  fswatch \
  hugo \
  kaitai-struct-compiler \
  osqueryd \
  osqueryi \
  pdf2htmlEX \
  peco \
  pkgutil \
  printenv \
  qemu-edid \
  qemu-ga \
  qemu-img \
  qemu-io \
  qemu-nbd \
  qemu-system-aarch64 \
  qemu-system-alpha \
  qemu-system-arm \
  qemu-system-cris \
  qemu-system-hppa \
  qemu-system-i386 \
  qemu-system-lm32 \
  qemu-system-m68k \
  qemu-system-microblaze \
  qemu-system-microblazeel \
  qemu-system-mips \
  qemu-system-mips64 \
  qemu-system-mips64el \
  qemu-system-mipsel \
  qemu-system-moxie \
  qemu-system-nios2 \
  qemu-system-or1k \
  qemu-system-ppc \
  qemu-system-ppc64 \
  qemu-system-riscv32 \
  qemu-system-riscv64 \
  qemu-system-s390x \
  qemu-system-sh4 \
  qemu-system-sh4eb \
  qemu-system-sparc \
  qemu-system-sparc64 \
  qemu-system-tricore \
  qemu-system-unicore32 \
  qemu-system-x86_64 \
  qemu-system-xtensa \
  qemu-system-xtensaeb \
  r2 \
  redis-cli \
  sde \
  ti \
  wakatim \
  xed \
  yacc

# -----------------------------------------------------------------------------
# completion

function terraform_completion() {
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /usr/local/bin/terraform terraform
}

[[ $commands[az] ]] && autoload -Uz +X bashcompinit; bashcompinit; zsh-defer source "${HOMEBREW_PREFIX}/opt/azure-cli/etc/bash_completion.d/az"
[[ $commands[hatch] ]] && zsh-defer source "${HOMEBREW_PREFIX}/opt/hatch/share/zsh/site-functions/_hatch"
[[ $commands[parallel] && -f "${prefix}/opt/parallel/bin/env_parallel.zsh" ]] && { zsh-defer source "${prefix}/opt/parallel/bin/env_parallel.zsh" }
[[ $commands[terraform] ]] && terraform_completion()

[[ -f "${prefix}/google-cloud-sdk/completion.zsh.inc" ]] && { source "${prefix}/google-cloud-sdk/completion.zsh.inc" }

# -----------------------------------------------------------------------------
# version manager

## pyenv
if [[ $commands[pyenv] ]]; then
  export PYENV_ROOT="${prefix}/var/pyenv"
  alias pyenv="env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto ${PYTHON_CONFIGURE_OPTS}' PYTHON_CFLAGS='-march=x86-64-v4 -mtune=native ${PYTHON_CFLAGS}' pyenv"
fi

## jenv
if [[ $commands[jenv] ]]; then
  export JENV_ROOT="${prefix}/var/jenv"
  export JENV_SHELL='zsh'
  export JENV_LOADED=1
  unset JAVA_HOME
  unset JDK_HOME
  [[ -f "${HOMEBREW_PREFIX}/opt/jenv/libexec/completions/jenv.zsh" ]] && source "${HOMEBREW_PREFIX}/opt/jenv/libexec/completions/jenv.zsh"
fi
