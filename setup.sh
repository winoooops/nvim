#!/usr/bin/env bash
# setup.sh — one-time setup after cloning this repo on a new machine.
# Run from the repo root: cd ~/.config/nvim && bash setup.sh
#
# What it does:
#   1. Symlinks tmux.conf → ~/.tmux.conf
#   2. Installs TPM (tmux plugin manager) if missing
#   3. Installs tmux plugins via TPM
#   4. First nvim launch — lazy.nvim bootstraps and installs all plugins
#
# Prerequisites (install manually first — see docs/install.md):
#   - Neovim ≥ 0.11
#   - tmux ≥ 3.0
#   - git, make, gcc, ripgrep, fd, node, python3
#   - A Nerd Font (JetBrainsMono Nerd Font recommended)
#   - WSL2 only: win32yank.exe
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up from: $REPO_DIR"

# --- tmux ---
echo ""
echo "==> tmux setup"

# Symlink tmux.conf
if [ -f "$REPO_DIR/tmux/tmux.conf" ]; then
  if [ -L ~/.tmux.conf ]; then
    echo "    ~/.tmux.conf is already a symlink → $(readlink ~/.tmux.conf)"
  elif [ -f ~/.tmux.conf ]; then
    echo "    Backing up existing ~/.tmux.conf → ~/.tmux.conf.bak"
    cp ~/.tmux.conf ~/.tmux.conf.bak
  fi
  ln -sf "$REPO_DIR/tmux/tmux.conf" ~/.tmux.conf
  echo "    Symlinked: ~/.tmux.conf → $REPO_DIR/tmux/tmux.conf"
else
  echo "    WARNING: tmux/tmux.conf not found in repo — skipping"
fi

# Install TPM if missing
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
  echo "    TPM already installed at $TPM_DIR"
else
  echo "    Installing TPM..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo "    TPM installed"
fi

# Install tmux plugins (non-interactive)
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  echo "    Installing tmux plugins via TPM..."
  "$TPM_DIR/bin/install_plugins" 2>&1 | tail -5
  echo "    Tmux plugins installed"
else
  echo "    WARNING: TPM install_plugins not found — install plugins manually:"
  echo "    Start tmux, press Ctrl+b I"
fi

# Reload tmux config if tmux is running
if command -v tmux >/dev/null && tmux list-sessions >/dev/null 2>&1; then
  tmux source-file ~/.tmux.conf 2>/dev/null && echo "    Tmux config reloaded" || true
fi

# --- nvim ---
echo ""
echo "==> Neovim setup"

if ! command -v nvim >/dev/null 2>&1; then
  echo "    ERROR: nvim not found. Install Neovim >= 0.11 first."
  echo "    See: $REPO_DIR/docs/install.md"
  exit 1
fi

NVIM_VER="$(nvim --version | head -1)"
echo "    Found: $NVIM_VER"

echo "    Running headless launch to bootstrap lazy.nvim and install plugins..."
echo "    (This may take 1-3 minutes on first run)"
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
echo "    Plugins installed"

# --- summary ---
echo ""
echo "==> Setup complete!"
echo ""
echo "    Neovim: launch 'nvim' — everything is ready"
echo "    Tmux:   launch 'tmux' — config is loaded, plugins installed"
echo ""
echo "    For WSL2 clipboard: install win32yank.exe (see docs/install.md § 4)"
echo "    For AI terminals:   install claude, codex, gemini CLIs (see docs/install.md § 5)"
echo "    For lazygit:        install lazygit (see tmux/README.md or docs/install.md)"
echo ""
echo "    Full docs: $REPO_DIR/README.md"
echo "    Cheatsheet: $REPO_DIR/docs/cheatsheet.md"
