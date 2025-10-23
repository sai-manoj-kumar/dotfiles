#!/bin/bash

set -euo pipefail

echo "-----------------------------------------"
echo " Dotfiles Installation Started"
echo "-----------------------------------------"

# Setup git configuration
ln -sfv "$PWD/.gitconfig" "$HOME/.gitconfig"

## Install autojump before configuring shells (source-only approach)
install_autojump() {
	echo "Installing autojump..."

	if command -v autojump &>/dev/null; then
		echo "autojump is already installed."
		return
	fi

	tmpdir=$(mktemp -d)
	git clone https://github.com/wting/autojump.git "$tmpdir"
	(cd "$tmpdir" && ./install.py)
	rm -rf "$tmpdir"
}

# Ensure autojump is installed first so both Bash and Zsh have it available
install_autojump


# Run Bash setup
echo "Setting up Bash..."
./setup_bash.sh

# Run Zsh setup
echo "Setting up Zsh..."
./setup_zsh.sh

# ------------------------------------------------------------------------------
# Install utilities
# ------------------------------------------------------------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  TOOLS_TO_INSTALL=("jq" "nano" "tree")
  for tool in ${TOOLS_TO_INSTALL[@]}; do 
    which $tool >/dev/null || sudo apt install -y $tool
  done
fi

echo "-----------------------------------------"
echo " Dotfiles installation complete!"
echo "-----------------------------------------"