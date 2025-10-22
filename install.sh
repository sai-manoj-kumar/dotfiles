#!/bin/bash

set -euo pipefail

cd "$HOME/dotfiles"

# ------------------------------------------------------------------------------
# zsh
# ------------------------------------------------------------------------------

# Update bashrc
if [ -e ~/.bashrc ]; then
  mv ~/.bashrc ~/.bashrc.bak
fi
cp "$PWD/.bashrc" ~/.bashrc

# Update zshrc
if [ -e ~/.zshrc ]; then
  mv ~/.zshrc ~/.zshrc.bak
fi
cp "$PWD/.zshrc" ~/.zshrc

# ------------------------------------------------------------------------------
# oh-my-zsh
# ------------------------------------------------------------------------------

# oh-my-zsh
cp -rip "$PWD/.oh-my-zsh" ~/.oh-my-zsh

# Create symlinks in home folder

# ------------------------------------------------------------------------------
# git
# ------------------------------------------------------------------------------

ln -sfv "$PWD/.gitconfig" "$HOME/.gitconfig"

# Install autojump
git submodule foreach git pull
git submodule update --init --recursive
cd autojump
./install.py
cd ..
# --------------------------------------------------------------------------------

sudo chsh -s $(which zsh) coder
zsh
source ~/.zshrc
