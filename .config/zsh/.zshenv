# Ensure that a non-login, non-interactive shell has a defined environment.

if [[ -n "${TMUX}" || ( "${sHLVL}" -eq 1 && ! -o LOGIN ) && -s "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zprofile" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zprofile"
fi
