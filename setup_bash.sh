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

echo "Bash setup complete!"
