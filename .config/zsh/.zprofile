if [[ -n $ZPROFILE ]]; then zmodload 'zsh/zprof'; fi

# -----------------------------------------------------------------------------
# General environment variables

local prefix='/usr/local'

export LC_ALL='en_US.UTF-8'
export LC_CTYPE='en_US.UTF-8'
export LC_COLLATE='C'
export SHELL="${prefix}/bin/zsh"

local -h user_id=$(id -u)  ## exec
export XDG_RUNTIME_DIR="/usr/local/var/run/user/$user_id"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_DIRS="${prefix}/share:/usr/share"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
[ ! -d "$XDG_RUNTIME_DIR" ] && sudo mkdir -p "$XDG_RUNTIME_DIR"
[ ! -d "$XDG_CACHE_HOME" ] && mkdir -p "$XDG_CACHE_HOME"
[ ! -d "$XDG_CONFIG_DIRS" ] && sudo mkdir -p "$XDG_CONFIG_DIRS" && sudo chown $user_id "$XDG_CONFIG_DIRS"
[ ! -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"
[ ! -d "$XDG_DATA_HOME" ] && mkdir -p "$XDG_DATA_HOME"
[ ! -d "$XDG_STATE_HOME" ] && mkdir -p "$XDG_STATE_HOME"

# Homebrew
## Another envs set on $XDG_CONFIG_HOME/homebrew/brew.env.
export HOMEBREW_PREFIX="/usr/local"
export HOMEBREW_CACHE="$HOME/.cache/Homebrew"
export HOMEBREW_LOGS="$XDG_CACHE_HOME/Homebrew/logs"

export TERMINFO="${HOMEBREW_PREFIX}/opt/ncurses-head/share/terminfo"
export TERMINFO_DIRS="${HOME}/.local/share/terminfo:${HOMEBREW_PREFIX}/opt/ncurses-head/share/terminfo:${HOMEBREW_PREFIX}/opt/ncurses/share/terminfo:/Applications/kitty.app/Contents/Frameworks/kitty/terminfo:/usr/share/terminfo"
export EDITOR="${prefix}/bin/nvim"
export BROWSER="/usr/bin/open"
export PAGER="less"
export NETRC="${XDG_CONFIG_HOME}/netrc"
export UNICODE_VERSION='14.0.0'

# API secret tokens
if [[ -d ${XDG_DATA_HOME}/token ]]; then
  for f in $(find "${XDG_DATA_HOME}/token"); do
    source "$f"
  done
fi

# export MANWIDTH=999
export MANPAGER="${HOMEBREW_PREFIX}/opt/less-head/bin/less -isr"

# -----------------------------------------------------------------------------
# macOS

## Xcode toolchain
# NOTE(zchee): ":h" -- head - strip trailing path element
local -h _xcode_path="$(echo $(xcode-select -p)(:h:h))"  ## exec
export SDKROOT="${_xcode_path}/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
export MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion)"  ## exec

## xnu internal
# export MallocNanoZone='V2'
# export MallocAggressiveMadvise=1
# export MallocLargeCache=1
# export MallocSpaceEfficient=1
# export PTHREAD_MUTEX_DEFAULT_POLICY=1
# libmalloc
# export MallocExperiment='vm_force_4k_pages=1'

# -----------------------------------------------------------------------------
# Build

export CC="$(/usr/bin/xcrun -f clang)"  ## exec
export CXX="$CC++"

# -----------------------------------------------------------------------------
# zsh

export GIT_COMPLETION_SHOW_ALL=1

## terminal
export KITTY_CACHE_DIRECTORY="${XDG_CACHE_HOME}/kitty"
export KITTY_RUNTIME_DIRECTORY="${XDG_RUNTIME_DIR}"

# -----------------------------------------------------------------------------
# Commands

# gpg
export GNUPGHOME="${XDG_CONFIG_HOME}/gnupg"

# CMake
export CMAKE_BUILD_PARALLEL_LEVEL='32'
export CMAKE_CONFIG_TYPE='Release'
export CMAKE_GENERATOR='Ninja'
export CMAKE_OSX_ARCHITECTURES='x86_64'
export CMAKE_C_STANDARD='11'
export CMAKE_CXX_STANDARD='17'

# ccache
export USE_CCACHE=1
export CCACHE_DIR="${XDG_CACHE_HOME}/ccache"
export CCACHE_CPP2='yes'

# jemalloc
# export MALLOC_CONF="oversize_threshold:2097152,metadata_thp:always,percpu_arena:percpu,tcache:false,dss:primary"  # background_thread:true,
# export MALLOC_CONF="background_thread:true"
# export MALLOC_CONF='background_thread:true,metadata_thp:auto,dirty_decay_ms:30000,muzzy_decay_ms:30000,oversize_threshold:2097152,percpu_arena:percpu,tcache:false,dss:primary'

# git
export GIT_ALLOW_PROTOCOL='git:http:https:file:ssh'  # https://git-scm.com/docs/git#git-codeGITALLOWPROTOCOLcode, https://tip.golang.org/cmd/go/#hdr-Environment_variables
export GIT_CONFIG_NOSYSTEM=1

## grep
export GREP_COLOR='30;43'  # BSD
export GREP_COLORS='sl=49;39:cx=49;37:mt=43;30:fn=49;35:ln=49;38;5;154:bn=49;38;5;141:se=49;34'  # GNU

# cURL:
#  ref:
#  - https://gist.github.com/1stvamp/2158128#gistcomment-1573222
#  - https://github.com/smdahlen/vagrant-digitalocean/issues/123
[ -f "${HOMEBREW_PREFIX}/opt/ca-certificates/share/ca-certificates/cacert.pem" ] && export CURL_CA_BUNDLE="${HOMEBREW_PREFIX}/opt/ca-certificates/share/ca-certificates/cacert.pem"

# less
# export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
# export LESS='-f -N -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]'
# export LESS='-f -X -i -P ?f%f:(stdin). ?lb%lb?L/%L.. [?eEOF:?pb%pb\%..]'
# export LESSCHARSET='utf-8'
# LESS man page colors (makes Man pages more readable).
# export LESS_TERMCAP_mb=$'\E[01;31m'
# export LESS_TERMCAP_md=$'\E[01;31m'
# export LESS_TERMCAP_me=$'\E[0m'
# export LESS_TERMCAP_se=$'\E[0m'
# export LESS_TERMCAP_so=$'\E[01;44;33m'
# export LESS_TERMCAP_ue=$'\E[0m'
# export LESS_TERMCAP_us=$'\E[01;32m'

export LESSCHARSET='utf-8'
export LESSOPEN="| ${prefix}/bin/src-hilite-lesspipe.sh %s"
export LESSKEY="${XDG_CONFIG_HOME}/less/less"
export LESSHISTFILE="${HOME}/.history/lesshst"
export LESS_TERMCAP_mb="$(printf "\x1b[38;2;133;103;143m\x1b[6m")"
export LESS_TERMCAP_md="$(printf "\x1b[38;2;240;198;116m")"
export LESS_TERMCAP_me="$(printf "\x1b[0m")"
export LESS_TERMCAP_se="$(printf "\x1b[0m")"
export LESS_TERMCAP_so="$(printf "\x1b[38;2;240;198;116m\x1b[48;2;95;129;157m")"
export LESS_TERMCAP_ue="$(printf "\x1b[0m")"
export LESS_TERMCAP_us="$(printf "\x1b[38;2;129;162;190m\x1b[4m")"
if [[ -d "${HOMEBREW_PREFIX}/opt/ncurses-head" ]]; then
  export LESS_TERMCAP_mr="$(${HOMEBREW_PREFIX}/opt/ncurses-head/bin/tput rev)"
  export LESS_TERMCAP_mh="$(${HOMEBREW_PREFIX}/opt/ncurses-head/bin/tput dim)"
  export LESS_TERMCAP_ZN="$(${HOMEBREW_PREFIX}/opt/ncurses-head/bin/tput ssubm)"
  export LESS_TERMCAP_ZV="$(${HOMEBREW_PREFIX}/opt/ncurses-head/bin/tput rsubm)"
  export LESS_TERMCAP_ZO="$(${HOMEBREW_PREFIX}/opt/ncurses-head/bin/tput ssupm)"
  export LESS_TERMCAP_ZW="$(${HOMEBREW_PREFIX}/opt/ncurses-head/bin/tput rsupm)"
else
  export LESS_TERMCAP_mr="$(tput rev)"
  export LESS_TERMCAP_mh="$(tput dim)"
  export LESS_TERMCAP_ZN="$(tput ssubm)"
  export LESS_TERMCAP_ZV="$(tput rsubm)"
  export LESS_TERMCAP_ZO="$(tput ssupm)"
  export LESS_TERMCAP_ZW="$(tput rsupm)"
fi
# LESS_TERMCAP_mb= LESS_TERMCAP_md= LESS_TERMCAP_me= LESS_TERMCAP_se= LESS_TERMCAP_so= LESS_TERMCAP_ue= LESS_TERMCAP_us= LESS_TERMCAP_mr= LESS_TERMCAP_mh= LESS_TERMCAP_ZN= LESS_TERMCAP_ZV= LESS_TERMCAP_ZO= LESS_TERMCAP_ZW=

# tmux
export TMUX_CONF="${XDG_CONFIG_HOME}/tmux/tmux.conf"
export DEFAULT_TPM_PATH="${XDG_CONFIG_HOME}/tmux/plugins"

# groff
export GROFF_NO_SGR=true
export _NROFF_U=1

# Google Cloud SDK
export CLOUDSDK_INSTALL_DIR="${prefix}"
export CLOUDSDK_ROOT_DIR="${prefix}/google-cloud-sdk"
export CLOUDSDK_PYTHON="${HOMEBREW_PREFIX}/opt/python@3/bin/python3"
export CLOUDSDK_PYTHON_SITEPACKAGES=1  # for gcloud alpha logging tail (live tailing)
export CLOUDSDK_CONFIG="${XDG_CONFIG_HOME}/gcloud"
export BOTO_PATH="${XDG_CONFIG_HOME}/gsutil/boto"  # gsutil
export BIGQUERYRC="${XDG_CONFIG_HOME}/gcloud/bigqueryrc"  # https://github.com/google-cloud-sdk-unofficial/google-cloud-sdk/blob/v321.0.0/platform/bq/bq_utils.py#L21
export USE_GKE_GCLOUD_AUTH_PLUGIN='True'  # https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke

# jq
# null:false:true:numbers:strings:arrays:objects
export JQ_COLORS='2;37:0;35:0;35:0;33:0;32:1;39:1;39'

# circleci
export CIRCLECI_CLI_SKIP_UPDATE_CHECK=true

# ymattw/ydiff
export YDIFF_OPTIONS='-s -w0 --wrap'

# GNU Parallel
export PARALLEL_HOME="${XDG_CONFIG_HOME}/parallel"

# dircolors
source "${XDG_CONFIG_HOME}/zsh/modules/dircolors.zsh"

# locate
export LOCATE_PATH='/var/db/locate.database'

# gdb:
export GDBHISTFILE="${HOME}/.history/.gdb_history"

# radare2
export RHOMEDIR="${XDG_CONFIG_HOME}"
export RCFILE="${RHOMEDIR}/radare2/radare2rc"

# kubernetes
export KUBECONFIG="${XDG_CONFIG_HOME}/kube/config"
# export KUBECTL_EXTERNAL_DIFF="$HOME/bin/cdiff"
# export KUBECTL_EXTERNAL_DIFF='colordiff -N -u'
export KUBECTL_EXTERNAL_DIFF="dyff between --omit-header --set-exit-code"
export KUBERNETES_PATH="${prefix}/kubernetes"
## krew
export KREW_ROOT="${KUBECONFIG:h}/krew"
export KUBECTX_IGNORE_FZF=1
## kubebuilder
export EXTERNAL_PLUGINS_PATH="${XDG_CONFIG_HOME}/kubebuilder/plugins"
export KUBEBUILDER_ENABLE_PLUGINS=1
## kustomize
export KUSTOMIZE_ENABLE_ALPHA_COMMANDS='true'
## helm
export HELM_HOME="${XDG_CONFIG_HOME}/helm"
export HELM_DATA_HOME="${XDG_DATA_HOME}/helm"
export HELM_PLUGINS="${HELM_DATA_HOME}/plugins"
## helmfile
export HELMFILE_CACHE_HOME="${XDG_CACHE_HOME}/helmfile"
export HELMFILE_EXPERIMENTAL='true'
export HELMFILE_TEMPDIR='/tmp/helmfile'
export HELMFILE_V1MODE='true'  # ?
## Octant
export OCTANT_LISTENER_ADDR='localhost:54898'
export OCTANT_VERBOSE_CACHE=1
export OCTANT_PLUGIN_PATH="${XDG_CONFIG_HOME}/octant/plugins"
## telepresence
export SCOUT_DISABLE=1

## bufbuild/buf
export BUF_ALPHA_SUPPRESS_WARNINGS=1

# Docker
export DOCKER_BUILDKIT=1
export DOCKER_CLI_EXPERIMENTAL='enabled'
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"
export DOCKER_HIDE_LEGACY_COMMANDS=1
# export BUILDKIT_HOST='tcp://0.0.0.0:21120'
# export BUILDKIT_HOST='docker-container://buildx_buildkit_buildkitd'

## lima
export LIMA_DOCKER_HOST='tcp://127.0.0.1:2375'
export LIMA_HOME="${XDG_CONFIG_HOME}/lima"
# export QEMU_SYSTEM_X86_64="qemu-system-x86_64"
# export QEMU_SYSTEM_AARCH64="qemu-system-aarch64"

# Azure
export AZURE_CONFIG_DIR="${XDG_CONFIG_HOME}/azure"

# tldr
export TEALDEER_CONFIG_DIR="${XDG_CONFIG_HOME}/tealdeer"
export TEALDEER_CACHE_DIR="${XDG_CACHE_HOME/}tealdeer"

# ripgrep
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/rg/rg.conf"


# ansible
export ANSIBLE_LOCAL_TEMP="${XDG_CACHE_HOME/}ansible"


# github.com/joeyespo/grip
export GRIPHOME="${XDG_CONFIG_HOME}/grip"


# terraform, tofu
export TFENV_ROOT="${HOMEBREW_PREFIX}/opt/tfenv"
export TFENV_CONFIG_DIR="${XDG_CONFIG_HOME}/tfenv"
export TFENV_ENGINE='terraform' # 'tofu'
# export TFENV_ROOT="${HOMEBREW_PREFIX}/opt/tfenv-tofu"


# awscli
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME}/aws/credentials"


# shellcheck
export SHELLCHECK_OPTS='-e SC1090 -e SC1072 -e SC2044 -e SC2046 -e SC2148'


# sshrc
export SSHHOME="${XDG_CONFIG_HOME}"


# sharkdp/bat
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/bat.conf"


# weechat
export WEECHAT_HOME="${XDG_CONFIG_HOME}/weechat"


## file, libmagic
export MAGIC="${HOMEBREW_PREFIX}/opt/libmagic/share/misc/magic"


# nq
# TODO: Need more useful managing job tool written Go
export NQDIR='/tmp/nq'
[ ! -d "${NQDIR}" ] && mkdir -p "${NQDIR}"  # exec


# ansible-vault
## http://docs.ansible.com/ansible/devel/reference_appendices/config.html#default-vault-password-file
export ANSIBLE_VAULT_PASSWORD_FILE="${XDG_CONFIG_HOME}/ansible/vault_password"


# Vagrant
export VAGRANT_HOME="${XDG_CONFIG_HOME}/vagrant/vagrant.d"


# jtools
export JCOLOR=1  # ANSI Colors. Note you'll need 'less -R' if piping output
export JDEBUG=1  # Enhanced debug output. May be very verbose
# export JTOOLDIR=''  # path to search for companion jtool files (default: $PWD). Use this to force create a file, if one does not exist
# export NOPSUP=1  # Suppress NOPs in disassembly
# export JENTS=''  # Default entitlements (comma separated) for --sign
export JHASH='SHA256'  # Choice of Hash algorithm for signing (SHA1,SHA256 (default), SHA256T, SHA384)
# export JSHUDDUP=1  # Suppress stderr (risky, but useful)
export JDEBUGCS=1  # Debug output specifically for code signing operations. Useful to watch these step-by-step
# export WITHSIGBLOB=''  # Code signing: Also create an empty CMS blob (no longer a default due to CoreTrust)


# Misc:
export WAKATIME_HOME="$HOME/.config/wakatime"  # wakatime
export TRAVIS_CONFIG_PATH="${XDG_CONFIG_HOME}/travis"  # travis-cli
export GITBOOK_DIR=${XDG_CONFIG_HOME}/gitbook  # gitbook
# export DIRENV_CONFIG="${XDG_CONFIG_HOME}/direnv"

# -----------------------------------------------------------------------------
# Languages

# Go
export GOCACHE="${XDG_CACHE_HOME}/go/go-build"
export GOENV="${XDG_CONFIG_HOME}/go/env/env"
export GOAMD64='v4'
export GOCOVERDIR_BASE="/tmp/go/covdata"
# export GOTOOLCHAIN=go1.22.3+auto
# export GOTOOLCHAIN='local+auto'
# export GOEXPERIMENT=arenas,loopvar,cacheprog,newinliner,rangefunc
# export GOEXPERIMENT='arenas,loopvar,cacheprog,newinliner,rangefunc' # ,cgocheck2,pagetrace,cacheprog
# export GODEBUG='netdns=go'  # https://pkg.go.dev/net#hdr-Name_Resolution
# export GOTRACEBACK='all'  # https://github.com/golang/go/blob/go1.15.6/src/runtime/extern.go#L148-L167

## golang.org/x/tools
export GOPACKAGESDEBUG=true  # https://github.com/golang/tools/blob/11930bd9d71a/go/packages/golist.go#L33
export GOPACKAGESPRINTDRIVERERRORS=true  # https://github.com/golang/tools/blob/fe37c9e135b9/go/packages/external.go#L91
# export GOPACKAGESDRIVER=off # https://github.com/golang/tools/blob/fe37c9e135b9/go/packages/external.go#L45-L48

## github.com/gotestyourself/gotestsum
export GOTESTSUM_FORMAT='standard-verbose'  # https://github.com/gotestyourself/gotestsum#output-format

## golang.org/x/tools/gopls
export GOPLSCACHE="${XDG_CACHE_HOME}"

## github.com/google/go-containerregistry
export GGCR_EXPERIMENT_ESTARGZ=1

## github.com/sigstore/cosign
export COSIGN_EXPERIMENTAL=1

## github.com/golangci/golangci-lint
export GOLANGCI_LINT_CACHE="${XDG_CACHE_HOME}/golangci-lint"

## go-delve/delve
# export DELVE_DEBUGSERVER_PATH='/opt/llvm/15.0.3/bin/debugserver'

## gotest.tools/gotestsum
export GOTESTSUM_FORMAT='standard-verbose'

## go tool pprof
export PPROF_TMPDIR="/tmp/go/pprof"
export PPROF_BINARY_PATH="${XDG_DATA_HOME}/pprof/binaries"
## github.com/gogle/gops
export GOPS_CONFIG_DIR="/tmp/go/gops"

## github.com/oras-project/oras
export ORAS_CACHE="${XDG_CACHE_HOME}/oras"


# C/C++
# export CLANGD_AS_XPC_SERVICE='1'
## Conan
export CONAN_USER_HOME="${XDG_CONFIG_HOME}/c/conan"

## Swift
export SWIFTENV_ROOT="${prefix}/var/swiftenv"

# python
# export PYTHONOPTIMIZE='2'
# export PYTHONUNBUFFERED='1'
# export PYTHONASYNCIODEBUG=1  # enable the debug mode of the asyncio module
# export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/.pythonrc"  # for Python Repl
export PYTHONWARNINGS='ignore:DEPRECATION'  # ignore Python 2.7 EOL warning. ref: https://github.com/pypa/pip/issues/6207
# export PYTHONMALLOC='pymalloc'
# export PYTHONUSERBASE="${prefix}"  # for Intel Distributed Python
export USE_DAAL4PY_SKLEARN='YES'
## uv
export UV_CONFIG_FILE="${XDG_CONFIG_HOME}/uv/config.toml"
export UV_TOOLCHAIN_DIR="${XDG_DATA_HOME}/uv"
export UV_CACHE_DIR="${XDG_CACHE_HOME}/uv"
## ptpython
export PTPYTHON_CONFIG_HOME="$XDG_CONFIG_HOME/ptpython"
## Jupyter
export JUPYTER_RUNTIME_DIR="${XDG_RUNTIME_DIR}/jupyter"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"
export JUPYTER_PATH="${XDG_DATA_HOME}/jupyter"
## IPython
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
## joeyespo/grip
export GRIPHOME="${XDG_CONFIG_HOME}/grip"
## conda
export CONDA_PREFIX=
## mamba
# export MAMBARC="${XDG_CONFIG_HOME}/conda/mambarc"
## kaggle
export KAGGLE_CONFIG_DIR="${XDG_CONFIG_HOME}/kaggle"

# Rust
export RUST_HOME="${prefix}/rust"
export RUSTUP_HOME="${RUST_HOME}/rustup"
export RUSTUP_TOOLCHAIN='nightly'
export CARGO_HOME="${RUST_HOME}/cargo"
export RUSTFLAGS='-C target-cpu=x86-64-v4 -C opt-level=3 -C force-frame-pointers=on -C debug-assertions=off -C incremental=on -C overflow-checks=off -C panic=abort -C codegen-units=1 -C embed-bitcode=yes -Z dylib-lto -Z location-detail=none -C strip=symbols -C target-feature=+aes,+avx,+avx2,+avx512f,+avx512dq,+avx512cd,+avx512bw,+avx512vl,+avx512vnni'  # -C link-arg=-fuse-ld=lld
export NUM_JOBS='32'
export CARGO_BUILD_JOBS='32'
export CARGO_BUILD_TARGET='x86_64-apple-darwin'
export RUSTC_WRAPPER='sccache'
# export RUST_SRC_PATH="${RUSTUP_HOME}/toolchains/nightly-x86_64-apple-darwin/lib/rustlib/src/rust/src"
# export CARGO_UNSTABLE_SPARSE_REGISTRY=true

# Node
export NODE_REPL_HISTORY="${HOME}/.history/node_repl_history"
export DISABLE_OPENCOLLECTIVE='true'  # https://twitter.com/linda_pp/status/1148764982244286464
export COREPACK_HOME="${prefix}/var/node/corepack"
# export UV_THREADPOOL_SIZE='16'

# Java
# export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"  # exec
# export JAVA_HOME=$(/usr/libexec/java_home -v 12)  # exec
# export GRADLE_HOME="${HOMEBREW_PREFIX}/opt/gradle/libexec"
# GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"
# GRADLE_OPTS='-Xms512m -Xmx512m -XX:MaxMetaspaceSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8'
# export GRADLE_USER_HOME GRADLE_OPTS

# perl
export PERL5LIB="${prefix}/var/perl5/lib/perl5"
export PERL_MB_OPT="--install_base ${prefix}/var/perl5"
export PERL_MM_OPT="INSTALL_BASE=${prefix}/var/perl5"

# OCaml
export OPAMROOT="${prefix}/opam"
if [[ -d "${OPAMROOT}" ]]; then
  export CAML_LD_LIBRARY_PATH="${HOME}/.opam/system/lib/stublibs:${prefix}/lib/ocaml/stublibs"
  export OPAMUTF8MSGS='1'
  export OCAML_TOPLEVEL_PATH="${HOME}/.opam/system/lib/toplevel"
  export OPAMJOBS=9
  export PERL5LIB="${HOME}/.opam/system/lib/perl5:${HOME}/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
  export PERL_LOCAL_LIB_ROOT="${HOME}/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
  export PERL_MB_OPT="--install_base \"${HOME}/perl5\""
  export PERL_MM_OPT="INSTALL_BASE=${HOME}/perl5"
fi


# Ruby
export BUNDLE_CACHE_PATH="${XDG_CACHE_HOME}/bundle"
## rbenv
export RBENV_ROOT="${prefix}/var/rbenv"
export RUBY_BUILD_HTTP_CLIENT='aria2c'  # use curl instead of aria2c
export RUBY_BUILD_CACHE_PATH="${XDG_CACHE_HOME}/rbenv"

# Miscellaneous
## asciidoc
export XML_CATALOG_FILES="${prefix}/etc/xml/catalog"
## Adobe AFDKO
export FDK_EXE="${HOMEBREW_PREFIX}/opt/afdko/Tools/osx"
## postgresql
export PGDATA="${prefix}/var/postgres"

# -----------------------------------------------------------------------------
# Neovim

# [[ ! -d "$XDG_DATA_HOME/nvim/log" ]] && mkdir -p "$XDG_DATA_HOME/nvim/log"
# Usually, disable set $NVIM_LISTEN_ADDRESS(unix domain filepath). if empty, nvim creates socket file and set $NVIM_LISTEN_ADDRESS only within nvim instance automatically.
# export NVIM_LISTEN_ADDRESS='/tmp/nvim'
export NVIM_LOG_FILE="${XDG_STATE_HOME}/nvim/log"
# NOTE: If set $NVIM_PYTHON_LOG_FILE, nvim will be always the dump python-client log. Normally off.
# export NVIM_PYTHON_LOG_FILE="${HOME}/.local/var/log/nvim/python/python-client.log" && export NVIM_PYTHON_LOG_LEVEL="DEBUG"

# Plugins
## deoplete.nvim
# export DEOPLETE_LOG_FILE="/tmp/deoplete.log"
# export DEOPLETE_ZSH_CACHE_DIR="${XDG_CACHE_HOME}/nvim/deoplete/zsh"

## zchee/nvim-go
export NVIM_GO_LOG_LEVEL='debug'
export NVIM_GO_LOG_FILE="/tmp/nvim-go.log"

## zchee/nvim-lsp
# export NVIM_LSP_DEBUG='true'
# export NVIM_LSP_LOG_LEVEL='debug'
# export NVIM_LSP_LOG_FILE="/tmp/nvim-lsp.log"
# export NVIM_LSP_CPU_PROFILE='/tmp/go/nvim-lsp.prrof'
# export NVIM_LSP_GCP_PROJECT_ID='zchee-io'
# export NVIM_LSP_GSA_PATH="${XDG_CONFIG_HOME}/gcloud/credentials/zchee-io/cloudprofiler.json"

# Bazel
# TODO(zchee): needs?
#   https://github.com/bazelbuild/rules_cc/blob/7fdc27c099bd6e30bf8e112923c8f1b86acd34af/cc/private/toolchain/cc_configure.bzl#L54-L55
# export BAZEL_USE_XCODE_TOOLCHAIN='1'
# export TEST_TMPDIR="$XDG_CACHE_HOME/bazel"
export ANDROID_HOME="${HOME}/Library/Android/sdk"

# -----------------------------------------------------------------------------
# Environment variables

local -a envs
envs=(
  CPATH
  LIBRARY_PATH
  LD_LIBRARY_PATH
  DYLD_LIBRARY_PATH
  PKG_CONFIG_PATH

  C_INCLUDE_PATH
  OBJC_INCLUDE_PATH
  CPLUS_INCLUDE_PATH
  OBJCPLUS_INCLUDE_PATH
)
# Some special paths (PATH, FPATH, MANPATH, CDPATH) are set automatically by the shell
# No need -xT flag (create the nameed list)
for env in $envs[@]; do
  typeset -xT ${env} ${env:l}
done

# [@] is toField with space, ':l' is toLower
typeset -gU path fpath manpath cdpath "$envs[@]:l"

path=(
  ${HOME}/{bin,bin/dtrace}(N-/)  # dotfiles and dtrace scripts

  # Go runtime toolchain
  ${prefix}/go/bin(N-/)  # Go core runtimes
  ${HOME}/go/bin(N-/)  # Go binaries

  ${HOME}/.local/bin(N-/)  # Unix user local

  ${HOME}/src/github.com/zchee/jtools/bin(N-/)  # The jtools

  /opt/local/{bin,libexec}(N-/)    # evacuation space for duplicate commands. such as Xcode builtin vs LLVM binaries
  /opt/watchman/bin(N-/)
  /Library/Apple/usr/bin(N-/)      # Apple rvictl command
  /Library/Apple/usr/libexec(N-/)

  ${DOCKER_CONFIG}/bin(N-/)          # docker binaries
  ${DOCKER_CONFIG}/cli-plugins(N-/)  # docker plugins

  ${KUBERNETES_PATH}/bin(N-/)      # anthos config management
  ${KUBECONFIG:h}/plugins(N-/)     # kubectl plugins
  ${KUBECONFIG:h}/completions(N-/) # kubectl plugins zsh completion; See https://qiita.com/superbrothers/items/65a16f5139b52e1b9d56
  ${KUBEBUILDER_ASSETS}(N-/)       # kubebuilder

  # brew
  ${HOMEBREW_PREFIX}/opt/bison/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin(N-/)
  ${HOMEBREW_PREFIX}/opt/file-head/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin(N-/)
  ${HOMEBREW_PREFIX}/opt/flex/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/gettext/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/git-head/libexec/git-core(N-/)
  ${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin(N-/)
  ${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin(N-/)
  ${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin(N-/)
  ${HOMEBREW_PREFIX}/opt/libressl/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/libxml2/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/lsof/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/make/libexec/gnubin(N-/)
  ${HOMEBREW_PREFIX}/opt/ncurses-head/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/openssl-quic/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/qt/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/qt@5/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/sqlite3/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/texinfo/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/unzip/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/yq/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/zip/bin(N-/)
  ${HOMEBREW_PREIX}/opt/gawk/libexec/gnubin(N-/)
  # ${HOMEBREW_PREFIX}/opt/python@3.11/bin(N-/)
  # ${HOMEBREW_PREFIX}/opt/python@3.11/libexec/bin(N-/)
  # ${HOMEBREW_PREFIX}/opt/python@3.12/bin(N-/)
  # ${HOMEBREW_PREFIX}/opt/python@3.12/libexec/bin(N-/)

  # cask
  ${prefix}/texlive/2021basic/bin/universal-darwin(N-/)  # basictex

  ${_xcode_path}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin(N-/)      # Xcode toolchain
  ${_xcode_path}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/libexec(N-/)  # Xcode toolchain libexec
  ${_xcode_path}/Contents/Developer/Makefiles/pb_makefiles(N-/)

  # kitty
  /Applications/kitty.app/Contents/MacOS(N-/)

  # orbstack
  ${HOME}/.orbstack/bin(N-/)

  # LLVM
  ## clangd
  /opt/llvm/clangd/bin(N-/)
  ## LLVM toolchain
  ## brewed LLVM
  /usr/local/opt/llvm/{bin,libexec}(N-/)
  ## self compile
  /opt/llvm/devel/{bin,libexec}(N-/)  # LLVM devel binaries
  # /opt/llvm/devel/Library/Frameworks/LLDB.framework/Resources(N-/)  # LLVM lldb binaries. darwin-debug, debugserver, lldb-argdumper and lldb-server
  # /opt/llvm/lldb-mi/bin(N-/)  # lldb-tools/lldb-mi
  # /opt/llvm/stable/{bin,libexec}(N-/)  # LLVM devel binaries
  # /opt/llvm/stable/Library/Frameworks/LLDB.framework/Resources(N-/)  # LLVM lldb binaries. darwin-debug, debugserver, lldb-argdumper and lldb-server
  /Library/Developer/Toolchains/swift-latest.xctoolchain/System/Library/PrivateFrameworks/LLDB.framework/Resources(N-/)  # Apple swift-lldb binaries. darwin-debug, lldb-argdumper, lldb-server and repl_swift
  ${_xcode_path}/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources(N-/)  # Xcode lldb binaries. darwin-debug, debugserver, lldb-argdumper, lldb-server and repl_swift

  # opt
  /opt/intel/oneapi/compiler/latest/mac/bin/intel64(N-/)
  # /opt/intel/psxe/bin(N-/)                     # Intel Parallel Studio XE Composer Edition for C++ macOS
  /opt/intel/ispc/bin(N-/)
  /opt/intel/pin/intel64/bin(N-/)              # pinbin, pindb
  /opt/intel/pin(N-/)                          # pintool
  /opt/intel/xed/bin(N-/)                      # Intel X86 Encoder Decoder (Intel XED)
  /opt/intel/sde(N-/)                          # Intel Software Development Emulator (Intel SDE)
  /opt/ghidra(N-/)                             # Ghidra
  /opt/datadog-agent/bin/agent(N-/)
  /opt/osquery/bin(N-/)
  /opt/yarn/nightly/bin(N-/)                   # yarn nightly
  /opt/cern/cling/bin(N-/)                     # CERN Cling
  /opt/cern/root/bin(N-/)                      # CERN Root
  /opt/vmware/bin(N-/)                         # VMware Fusion
  /opt/parallels/bin(N-/)                      # Parallels Desktop
  /opt/xhyve/bin(N-/)                          # xhyve
  /opt/docker/bin(N-/)                         # Docker.app
  /opt/xnu/bin(N-/)                            # darwin xnu
  /opt/djb/{daemontools,pty,ptyget,redo}(N-/)  # djb tools

  /Applications/Docker.app/Contents/Resources/bin(N-/)
  /Applications/Docker.app/Contents/MacOS(N-/)

  /Applications/Kui.app/Contents/Resources(N-/)  # github.com/kubernetes-sigs/kui

  /Applications/Falcon.app/Contents/Resources(N-/)  # falconctl v6
  /Library/CS(N-/)  # falconctl v5

  ${prefix}/MacGPG2/bin(N-/)                                 # MacGPG2

  ${prefix}/codeql(N-/)                                      # CodeQL

  ${prefix}/var/luarocks/bin(N-/)  # Luarocks

  /Applications/IDA/idabin(N-/)  # IDA Pro binaries
)

## kubectl-krew
(( $+KREW_ROOT )) && path+="${KREW_ROOT}/bin"

## Languages
(( $+CARGO_HOME )) && path+="${CARGO_HOME}/bin"  # rust

(( $+SWIFTENV_ROOT )) && path+=( "${SWIFTENV_ROOT}/bin" "${SWIFTENV_ROOT}/shims" )  # swift

export PIPX_HOME="${prefix}/var/pipx"
export PIPX_BIN_DIR="${prefix}/share/pipx"
export PIPX_DEFAULT_PYTHON="${HOMEBREW_PREFIX}/opt/python@3.11/bin/python3.11"
[ -d ${PIPX_BIN_DIR} ] && path+="${PIPX_BIN_DIR}"

## rbenv
[ -d ${RBENV_ROOT} ] && path+="${RBENV_ROOT}/shims"

## nodenv
export NODENV_ROOT="${prefix}/var/nodenv"
export NODE_BUILD_CACHE_PATH="${XDG_CACHE_HOME}/nodenv"
export NODE_BUILD_ARIA2_OPTS='--file-allocation none -c --max-connection-per-server 16 --min-split-size 1M --optimize-concurrent-downloads'
[ -d ${NODENV_ROOT} ] && path+="${NODENV_ROOT}/shims"

## Swift
export MINT_PATH="${prefix}/var/mint"
export MINT_LINK_PATH="${MINT_PATH}/bin"
[ -d ${MINT_LINK_PATH} ] && path+=${MINT_LINK_PATH}

## jenv
# export JENV_ROOT="${prefix}/var/jenv"
# export JENV_SHELL=zsh
# export JENV_LOADED=1
# unset JAVA_HOME
# unset JDK_HOME
# jenv rehash 2>/dev/null
# jenv refresh-plugins
jenv() {
  type typeset &> /dev/null && typeset command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  enable-plugin|rehash|shell|shell-options)
    eval `jenv "sh-$command" "$@"`;;
  *)
    command jenv "$command" "$@";;
  esac
}
[ -d ${JENV_ROOT} ] && path+="${JENV_ROOT}/shims"

## bun
export BUN_INSTALL="${prefix}/var/bun"
[ -d ${BUN_INSTALL} ] && path+="${BUN_INSTALL}/bin"

## Java
(( $+JAVA_HOME )) && path+="${JAVA_HOME}/bin"

path+=(
  # lazy
  ${HOMEBREW_PREFIX}/opt/ruby/bin(N-/)
  ${HOMEBREW_PREFIX}/opt/ruby/libexec/gembin(N-/)

  # user local Unix filesystem
  ${prefix}/bin(N-/)
  ${prefix}/sbin(N-/)
  ${prefix}/libexec(N-/)

  ${prefix}/var/node/bin(N-/)  # npm

  ${prefix}/google-cloud-sdk/bin(N-/)                        # Google Cloud SDK
  ${prefix}/google-cloud-sdk/platform/google_appengine(N-/)  # App Engine toolchains

  ${HOME}/.local/share/yarn/bin(N-/) # yarn
  /usr/local/var/yarn/bin(N-/) # yarn
  ${HOME}/.opam/system/bin(N-/)      # OCaml

  ${_xcode_path}/Contents/Developer/usr/bin(N-/)  # Xcode Developer binaries

  # Unix filesystem
  /bin(N-/)
  /sbin(N-/)
  /usr/bin(N-/)
  /usr/sbin(N-/)
  /usr/libexec(N-/)

  # macOS System binaries
  /System/Library/Filesystems/apfs.fs/Contents/Resources(N-/)  # Apple File System(apfs) command line tools
  /System/Library/CoreServices(N-/)                            # CoreServices system binaries

  # Applications
  /Library/Filesystems/osxfuse.fs/Contents/Resources(N-/)               # osxfuse
  /Applications/Docker.app/Contents/Resources/cli-plugins(N-/)          # Docker.app
  /Applications/kitty.app/Contents/Frameworks/kitty/kitty/launcher(N-/) # kitty
  /Applications/ScreenFlow.app/Contents/Resources(N-/)                  # ScreenFlow
  /Applications/Wireshark.app/Contents/MacOS(N-/)                       # Wireshark
  /Applications/Lazarus(N-/)                                            # Lazarus
  /usr/local/anaconda3/bin(N-/)                                         # brew csaked anaconda3
)

fpath=(
  ${XDG_CONFIG_HOME}/zsh/functions(N-/)                                                # user Zsh functions
  ${XDG_CONFIG_HOME}/zsh/modules/zsh-defer(N-/)
  # ${XDG_CONFIG_HOME}/zsh/plugins(N-/)                                                # Zsh plugins
  # ${XDG_CONFIG_HOME}/zsh/prompt(N-/)                                                   # Zsh prompt

  ${XDG_CONFIG_HOME}/zsh/completions(N-/)                                              # user completions
  ${HOME}/src/github.com/zchee/zsh-completions/src/go(N-/)                             # zchee/zsh-completions/go
  ${HOME}/src/github.com/zchee/zsh-completions/src/macOS(N-/)                          # zchee/zsh-completions/macOS
  ${HOME}/src/github.com/zchee/zsh-completions/src/zsh(N-/)                            # zchee/zsh-completions/zsh
  ${HOMEBREW_PREFIX}/opt/zsh-completions/share/zsh-completions(N-/)                    # zsh-users/zsh-completions

  ${prefix}/share/zsh/site-functions(N-/)                                                # Zsh default fpath
  ${prefix}/share/zsh/functions(N-/)                                                     # Zsh default fpath
)

manpath=(
  # gcloud man page
  ${CLOUDSDK_ROOT_DIR}/help/man(N-/)

  ${HOMEBREW_PREFIX}/opt/bison/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/coreutils/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/curl-quic/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/file-head/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/findutils/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/gettext/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/git-head/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/gnu-sed/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/gnu-tar/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/gnu-which/libexec/gnuman(N-/)
  ${HOMEBREW_PREFIX}/opt/grep/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/libressl/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/libxml2/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/lsof/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/make/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/ncurses-head/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/openssl/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/sqlite3/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/texinfo/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/universal-ctags/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/unzip/share/man(N-/)
  ${HOMEBREW_PREFIX}/opt/zip/share/man(N-/)

  /usr/share/man(N/)
  ${prefix}/share/man(N-/)

  # /opt
  /opt/intel/intelpython3/bin(N-/)  # Intel Distribution for Python for macOS
  /opt/local/share/man(N-/)
  /opt/llvm/devel/share/man(N-/)
  /opt/llvm/stable/share/man(N-/)

  ${_xcode_path}/Contents/Developer/usr/share/man(N-/)
  ${_xcode_path}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/share/man(N-/)
  /Library/Apple/usr/share/man(N-/)
  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/share/man(N-/)

  /opt/parallels/share/man(N/)
  /opt/X11/share/man(N/)
  ${prefix}/MacGPG2/share/man(N/)

  /Applications/Wireshark.app/Contents/Resources/share/man(N-/)
)

# cpath not respect include path order such as '${prefix}/include(N-/)'
# cpath=()

# c_include_path=(
#   $HOME/.local/include(N-/)
#   ${prefix}/include(N-/)
#   $_xcode_path/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include(N-/)
# )

# cplus_include_path=(
#   $HOME/.local/include(N-/)
#   ${prefix}/include(N-/)
#   $_xcode_path/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/11.0.3/include(N-/)
#   $_xcode_path/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include(N-/)
# )

# objc_include_path=(
# )

# objcplus_include_path=(
# )

pkg_config_path=(
  ${HOMEBREW_PREFIX}/opt/curl-quic/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/ncurses-head/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/python@3.11/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/python@3.12/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/qt/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/ruby/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/sqlite3/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/qt/lib/pkgconfig(N-/)
  ${HOMEBREW_PREFIX}/opt/qt@5/lib/pkgconfig(N-/)

  ${prefix}/lib/pkgconfig(N-/)
  /usr/lib/pkgconfig(N-/)
)

cdpath=(
  ${HOME}/go/src/github.com(N-/)
  ${HOME}/go/src/github.com/gaudiy(N-/)
  ${HOME}/go/src(N-/)
  ${HOME}/src/github.com(N-/)
  ${HOME}/src/github.com/gaudiy(N-/)
  ${HOME}/cue/src(N-/)
)

# TODO(zchee): trim ':' separator
# cflags=(
#   -I${HOMEBREW_PREFIX}/opt/ncurses/include
#   -I${HOMEBREW_PREFIX}/opt/gettext/include
#   -I${HOMEBREW_PREFIX}/opt/qt/include
# )

# TODO(zchee): trim ':' separator
# ldflags=(
#   -L${HOMEBREW_PREFIX}/opt/ncurses/lib
#   -L${HOMEBREW_PREFIX}/opt/gettext/lib
#   -L${HOMEBREW_PREFIX}/opt/qt/lib
# )

# LIBRARY_PATH is the used by compiler before compilation to search directories containing static libraries.
# library_path=(
#   $_xcode_path/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks(N-/)
#   $_xcode_path/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks(N-/)
# )

# LD_LIBRARY_PATH is the used by program to search directories containing shared libraries.
# ld_library_path=(
#   $_xcode_path/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks(N-/)
#   $_xcode_path/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks(N-/)
# )

dyld_library_path=(
  ${HOMEBREW_PREFIX}/opt/python@3.12/Frameworks/Python.framework/Versions/3.12/lib(N-/)
  ${HOMEBREW_PREFIX}/opt/python@3.11/Frameworks/Python.framework/Versions/3.11/lib(N-/)
)

unset user_id
unset _xcode_path
