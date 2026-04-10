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

## 2. System tools

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

## 3. JetBrainsMono Nerd Font

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

## 4. WSL2 clipboard bridge (WSL2 only)

`win32yank.exe` lets yanks in Neovim (Linux side) flow to the Windows clipboard. Without this, `y` works inside nvim but can't paste into Windows apps.

```bash
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/
which win32yank.exe
```

Verify: `echo hi | win32yank.exe -i` then paste in Windows Notepad → `hi`.

## 5. AI CLIs (for the `<leader>t*` terminals)

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

## 6. Clone this config

```bash
git clone https://github.com/winoooops/nvim.git ~/.config/nvim
nvim
```

On first launch, lazy.nvim clones itself and installs every plugin from `lazy-lock.json`. This takes 1-3 minutes and only happens once per machine.

## 7. Post-install check

```
:checkhealth
```

Expect green/OK for: core, mason, treesitter, telescope, lazy. Yellow/warn is acceptable for optional providers (Perl, Ruby).

If anything fails: [troubleshooting.md](troubleshooting.md).
