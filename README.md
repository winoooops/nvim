# Neovim + Tmux 2026

Cross-platform dev environment optimized for agent-driven development (Claude Code, Codex, Gemini). Neovim config + tmux config in one repo, syncing identically across macOS, native Linux, and WSL2.

> **Philosophy:** in 2026, Neovim's primary job is not typing code — it's **reviewing agent output**. Every keybind in this config is optimized for that workflow. See [docs/user-guide.md](docs/user-guide.md#philosophy) for the full rationale.

## Quick start (fresh machine)

```bash
# 1. Install prerequisites (see docs/install.md for per-OS details)
#    Neovim >= 0.11, tmux >= 3.0, git, make, gcc, ripgrep, fd, node, python3
#    + a Nerd Font (JetBrainsMono recommended)

# 2. Clone
git clone git@github.com:winoooops/nvim.git ~/.config/nvim

# 3. Run the setup script — installs everything (nvim plugins + tmux plugins + symlinks)
cd ~/.config/nvim && bash setup.sh
```

That's it. `setup.sh` handles:
- Symlinks `tmux/tmux.conf` → `~/.tmux.conf` (backs up any existing one)
- Installs TPM (tmux plugin manager) if missing
- Installs tmux plugins (tmux-which-key, tmux-resurrect)
- Runs `nvim --headless` to bootstrap lazy.nvim and install all 35 plugins from `lazy-lock.json`

## Requirements

- Neovim ≥ 0.11
- tmux ≥ 3.0
- git, make, unzip, gcc, ripgrep, fd, Node.js, Python 3
- A Nerd Font (JetBrainsMono Nerd Font recommended)
- **WSL2 only:** `win32yank.exe` for Windows clipboard bridge

Full per-OS install: [docs/install.md](docs/install.md)

## 📚 Documentation

**Start here:**

| Doc | Purpose |
|---|---|
| 📇 [docs/cheatsheet.md](docs/cheatsheet.md) | **One-page quick reference.** Print it, screenshot it. |
| 📖 [docs/user-guide.md](docs/user-guide.md) | **Walkthrough of daily workflows + recipes.** Read once, refer back. |

**Reference:**

| Doc | Purpose |
|---|---|
| [docs/keybindings.md](docs/keybindings.md) | Exhaustive nvim keymap table |
| [tmux/README.md](tmux/README.md) | Tmux keybindings + setup |
| [docs/install.md](docs/install.md) | Per-OS install, fonts, clipboard bridge |
| [docs/updating.md](docs/updating.md) | Update Neovim and sync plugins across machines |
| [docs/troubleshooting.md](docs/troubleshooting.md) | Common issues and fixes |
| [lua/core/README.md](lua/core/README.md) | Core module architecture |
| [lua/plugins/README.md](lua/plugins/README.md) | Plugin domain index |
| [CHANGELOG.md](CHANGELOG.md) | What changed between syncs |

## Key features

- **lazy.nvim** with committed `lazy-lock.json` — reproducible across machines
- **mason + lspconfig** — zero-config LSP installs
- **blink.cmp** — fast Rust-backed completion
- **conform.nvim + nvim-lint** — modern format/lint (replaces null-ls)
- **snacks.nvim** — dashboard, notifier, bufdelete in one
- **CodeCompanion.nvim** — in-editor AI chat (Claude / OpenAI / Ollama)
- **toggleterm** — vertical-split default with named AI CLI terminals
- **diffview.nvim + gitsigns** — agent diff review cockpit
- **Platform-aware clipboard** — WSL2 via win32yank, macOS/Linux native

## Architecture

```
~/.config/nvim/
├── setup.sh               ← run this on a fresh machine
├── init.lua               ← nvim entry point
├── lua/core/              ← options, keymaps, autocmds, platform detection
├── lua/plugins/           ← one file per plugin domain (ui, editor, git, lsp, ai, etc.)
├── tmux/tmux.conf         ← symlinked to ~/.tmux.conf by setup.sh
├── bin/wsl-clip-img       ← WSL2: Windows clipboard image → /tmp/*.png
├── docs/                  ← cheatsheet, user guide, install, keybindings, troubleshooting
└── legacy-2022/           ← archived 2022 config for reference
```

See [lua/core/README.md](lua/core/README.md) and [lua/plugins/README.md](lua/plugins/README.md).
