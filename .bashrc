# shellcheck shell=bash

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# change shell to zsh
if [[ ! $(jobs -l) ]]; then
  if [[ $- == *i* ]]; then
    export SHELL=/usr/bin/zsh
    # exec /usr/bin/zsh -l
  fi
fi
