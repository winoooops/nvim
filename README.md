# Neovim 2026

Cross-platform Neovim config optimized for agent-driven development (Claude Code, Codex, Gemini). Syncs identically across macOS, native Linux, and WSL2 via `lazy-lock.json`.

> **Philosophy:** in 2026, Neovim's primary job is not typing code — it's **reviewing agent output**. Every keybind in this config is optimized for that workflow. See [docs/user-guide.md](docs/user-guide.md#philosophy) for the full rationale.

## Quick start

```bash
git clone git@github.com:winoooops/nvim.git ~/.config/nvim
nvim
```

First launch bootstraps lazy.nvim and installs all plugins from the lockfile (1–3 minutes).

## Requirements

- Neovim ≥ 0.11
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
| [docs/keybindings.md](docs/keybindings.md) | Exhaustive keymap table |
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

See [lua/core/README.md](lua/core/README.md) and [lua/plugins/README.md](lua/plugins/README.md).
