# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Disable auto-update on rdev where there is no public internet access
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  DISABLE_AUTO_UPDATE="true"
fi

# zsh-autosuggestions config
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_USE_ASYNC="yes"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast git macos autojump zsh-autosuggestions timer extract encode64 alias-finder)

zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias cp="cp -v"
alias cls="clear; git status 2>/dev/null || echo 'Not in a git repository'"
alias l="ls"
alias lsa="ls -lap"

# ------------------------------------------------------------------------------
# Git aliases
# ------------------------------------------------------------------------------
alias g="git"
alias gs="git status"
alias gup="git fetch --prune origin; git prune; git pull; git clean -fdx"

# Set nano as default editor for git and other tools
export EDITOR="nano"
export VISUAL="nano"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# autojump config (installed via source to "$HOME/.autojump")
if [[ -s "$HOME/.autojump/etc/profile.d/autojump.sh" ]]; then
  source "$HOME/.autojump/etc/profile.d/autojump.sh"
fi
autoload -U compinit && compinit -u

bindkey '^I^I' autosuggest-accept

export PATH="$PATH:/export/content/linkedin/bin"
