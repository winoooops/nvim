# Installation

## 1. Neovim ≥ 0.11

### macOS
```bash
brew install neovim
```

### Linux (Debian/Ubuntu)
```bash
# Ubuntu 24.04+ ships 0.9, which is too old. Use the unstable PPA:
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
```

Arch:
```bash
sudo pacman -S neovim
```

### WSL2
Install inside WSL, not Windows:
```bash
sudo apt install neovim  # or use the PPA for 0.11
```

Verify: `nvim --version | head -1` → `NVIM v0.11.x` or later.

## 2. tmux ≥ 3.0

### macOS
```bash
brew install tmux
```

### Debian/Ubuntu
```bash
sudo apt install -y tmux
```

Verify: `tmux -V` → `tmux 3.x` or later.

## 3. System tools

### macOS
```bash
brew install git ripgrep fd node python3 gcc make unzip lazygit
```

### Debian/Ubuntu
```bash
sudo apt install -y git ripgrep fd-find nodejs npm python3 python3-pip build-essential unzip
# fd is installed as `fdfind` on Debian — symlink it:
mkdir -p ~/.local/bin && ln -sf "$(which fdfind)" ~/.local/bin/fd
# Install lazygit separately — see https://github.com/jesseduffield/lazygit#installation
```

## 4. JetBrainsMono Nerd Font

### macOS
```bash
brew install --cask font-jetbrains-mono-nerd-font
```
Then set it as your terminal font (iTerm2 / Ghostty / Alacritty / Kitty).

### Linux
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip
fc-cache -fv
```

### WSL2
Fonts must be installed in **Windows**, not WSL. Windows Terminal renders the font, WSL just emits characters.

1. Download `JetBrainsMono.zip` from [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases/latest).
2. Unzip, right-click each `.ttf`, "Install for all users".
3. Windows Terminal → Settings → your WSL profile → Appearance → Font face → `JetBrainsMono Nerd Font`.

## 5. WSL2 clipboard bridge (WSL2 only)

`win32yank.exe` lets yanks in Neovim (Linux side) flow to the Windows clipboard. Without this, `y` works inside nvim but can't paste into Windows apps.

```bash
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/
which win32yank.exe
```

Verify: `echo hi | win32yank.exe -i` then paste in Windows Notepad → `hi`.

## 6. AI CLIs (for the `<leader>t*` terminals)

```bash
npm i -g @anthropic-ai/claude-code
# codex: see https://github.com/openai/codex
# gemini: see https://github.com/google-gemini/gemini-cli (optional)
```

Set API keys in your shell rc:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

## 7. Clone and setup

```bash
git clone git@github.com:winoooops/nvim.git ~/.config/nvim
cd ~/.config/nvim
bash setup.sh
```

`setup.sh` does everything in one pass:
- Symlinks `tmux/tmux.conf` → `~/.tmux.conf` (backs up any existing config)
- Installs TPM (tmux plugin manager) + tmux plugins
- Bootstraps lazy.nvim and installs all nvim plugins from `lazy-lock.json` (1–3 minutes first time)

## 8. Post-install check

**Neovim:**
```
nvim
:checkhealth lazy vim.lsp vim.treesitter vim.provider telescope
```
Expect green/OK for all. Yellow/warn for optional providers is acceptable.

**Tmux:**
```bash
tmux
# Press Ctrl+b Space — which-key popup should appear
```

If anything fails: [troubleshooting.md](troubleshooting.md).
