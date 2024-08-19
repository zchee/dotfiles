#
# Executes commands at login post-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Execute code that does not affect the current session in the background.
{
  # TODO(zchee): needs it?
  stty pass8 -echo -iexten -cstopb 38400 -iutf8 -ixon stop undef start undef speed extb dec new cr0 -tabs > /dev/null 2>&1

  # Compile the completion dump to increase startup speed.
  zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    if command mkdir "${zcompdump}.zwc.lock" 2>/dev/null; then
      zcompile "$zcompdump"
      command rmdir "${zcompdump}.zwc.lock" 2>/dev/null
    fi
  fi
} &!
