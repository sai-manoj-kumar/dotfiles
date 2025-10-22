#!/bin/bash

set -euo pipefail

backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    echo "Backing up $file -> ${file}.bak"
    mv "$file" "${file}.bak"
  fi
}

echo "Configuring Zsh..."

backup_file ~/.zshrc
cp "$PWD/.zshrc" ~/.zshrc

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
  echo "Oh My Zsh already exists. Updating..."
  git -C "$HOME/.oh-my-zsh" pull --quiet
fi

# Ensure required plugins are installed (zsh-autosuggestions)
ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "Updating zsh-autosuggestions plugin..."
  git -C "$ZSH_CUSTOM/plugins/zsh-autosuggestions" pull --quiet || true
fi

# Copy custom plugins/themes if any
if [ -d "$PWD/.oh-my-zsh/custom" ]; then
  echo "Copying custom themes/plugins..."
  mkdir -p "$HOME/.oh-my-zsh/custom"
  cp -r "$PWD/.oh-my-zsh/custom/"* "$HOME/.oh-my-zsh/custom/" || true
fi

# Change shell
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  sudo chsh "$(id -un)" --shell "$(which zsh)"
fi

echo "Zsh setup complete."
