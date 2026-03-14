#!/bin/bash

set -euo pipefail

echo "-----------------------------------------"
echo " Dotfiles Installation Started"
echo "-----------------------------------------"

# Setup git configuration
ln -sfv "$PWD/.gitconfig" "$HOME/.gitconfig"

# ------------------------------------------------------------------------------
# Homebrew — install if not present (works on macOS and Linux)
# ------------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of this script
    if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed."
fi

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
  TOOLS_TO_INSTALL=("jq" "nano" "tree" "ripgrep" "tmux")
  for tool in ${TOOLS_TO_INSTALL[@]}; do 
    which $tool >/dev/null || sudo apt install -y $tool
  done
fi

# ------------------------------------------------------------------------------
# Dippy — auto-approve safe shell commands for AI coding assistants
# ------------------------------------------------------------------------------
install_dippy() {
    echo ""
    echo "Installing dippy..."

    if command -v dippy &>/dev/null; then
        echo "dippy is already installed."
        return
    fi

    if command -v brew &>/dev/null; then
        brew install ldayton/dippy/dippy
    elif command -v pip3 &>/dev/null; then
        pip3 install --user git+https://github.com/ldayton/Dippy.git
    else
        echo "Warning: Cannot install dippy (no brew or pip3 found). Skipping."
    fi
}

install_dippy

# ------------------------------------------------------------------------------
# Claude Code — install CLI + global settings, hooks, MCP servers, plugins
# ------------------------------------------------------------------------------
setup_claude_code() {
    echo ""
    echo "Setting up Claude Code..."

    # Install Claude Code CLI if not present
    if ! command -v claude &>/dev/null; then
        echo "Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code
    else
        echo "Claude Code already installed: $(claude --version 2>/dev/null || echo 'unknown')"
    fi

    CLAUDE_DIR="$HOME/.claude"
    mkdir -p "$CLAUDE_DIR"

    # Symlink CLAUDE.md (user preferences)
    ln -sfv "$PWD/.claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

    # Copy hook scripts (need to be executable)
    cp -v "$PWD/.claude/pre-commit-gate.sh" "$CLAUDE_DIR/pre-commit-gate.sh"
    chmod +x "$CLAUDE_DIR/pre-commit-gate.sh"

    cp -v "$PWD/.claude/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
    chmod +x "$CLAUDE_DIR/statusline-command.sh"

    # Generate settings.json from template — replace __HOME__ with actual $HOME
    if [[ -f "$PWD/.claude/settings.json.tpl" ]]; then
        sed "s|__HOME__|$HOME|g" "$PWD/.claude/settings.json.tpl" > "$CLAUDE_DIR/settings.json"
        echo "Generated $CLAUDE_DIR/settings.json"
    fi

    # Copy settings.local.json (generic permissions)
    if [[ ! -f "$CLAUDE_DIR/settings.local.json" ]]; then
        cp -v "$PWD/.claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"
    else
        echo "settings.local.json already exists, skipping"
    fi

    echo "Claude Code config complete."
}

setup_claude_code

echo "-----------------------------------------"
echo " Dotfiles installation complete!"
echo "-----------------------------------------"
