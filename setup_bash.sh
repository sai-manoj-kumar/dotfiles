#!/bin/bash

set -euo pipefail

backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    echo "Backing up $file -> ${file}.bak"
    mv "$file" "${file}.bak"
  fi
}

echo "Configuring Bash..."

backup_file ~/.bashrc
cp "$PWD/.bashrc" ~/.bashrc

# Install Starship prompt (idempotent)
install_starship() {
  echo "Installing Starship..."

  if command -v starship &>/dev/null; then
    echo "Starship is already installed."
    return
  fi

  if [[ "${OSTYPE:-}" == darwin* ]] && command -v brew &>/dev/null; then
    brew install starship
  else
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y || true
  fi

  if command -v starship &>/dev/null; then
    echo "Starship installation successful."
  else
    echo "Warning: Starship did not install successfully. Install manually: https://starship.rs"
  fi
}

install_starship

echo "Bash setup complete!"
