# Troubleshooting

## Icons render as tofu / squares
Nerd Font not set in your terminal emulator. See [install.md § 3](install.md#3-jetbrainsmono-nerd-font).

**WSL2 specifically:** the font must be installed in **Windows**, not WSL. Set Windows Terminal profile font to `JetBrainsMono Nerd Font`.

## WSL2: `y` works in nvim but paste fails in Windows apps
`win32yank.exe` not installed or not on `$PATH`. See [install.md § 4](install.md#4-wsl2-clipboard-bridge-wsl2-only).

Verify:
```bash
which win32yank.exe
echo test | win32yank.exe -i
```
Then try pasting in Notepad.

## `:checkhealth` reports Node.js missing
Mason needs Node for several LSP servers. Install Node.js ≥ 18 on this machine (see install.md § 2).

## Mason LSP install fails for a specific server
Run `:Mason` and select the failing server — the log panel shows the real error. Common causes: missing system compiler (`gcc`, `make`), missing Rust toolchain for rust_analyzer.

## `lazy-lock.json` conflicts when syncing across machines
Flow:
1. On machine A: `:Lazy sync` → `git commit lazy-lock.json` → `git push`
2. On machine B: `git pull` → `:Lazy restore`
3. Never commit an un-synced lockfile.

If you get a conflict anyway, take the version from the machine where you ran `:Lazy sync` most recently, then re-run `:Lazy restore` on all other machines.

## CodeCompanion: "no ANTHROPIC_API_KEY"
Export the key in your shell rc:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```
Restart the terminal session (or `source ~/.zshrc`). Then relaunch nvim.

## `<leader>g` opens but lazygit says "command not found"
Install lazygit on this machine — see [install.md § 2](install.md#2-system-tools).

## Treesitter parser errors on first launch
Run `:TSUpdate` once. If a specific parser fails, it usually means missing `gcc`/`clang`. Install a C compiler and retry.

## Treesitter errors after migrating to a new machine
If you see errors like `attempt to call method 'range' (a nil value)` from treesitter or markview.nvim, run `:Lazy update nvim-treesitter` followed by `:TSUpdate` to rebuild all parser binaries for the new platform.

## Neovim version too old (< 0.11)
Plugins like blink.cmp and snacks.nvim require 0.11+. Upgrade nvim — see [install.md § 1](install.md#1-neovim--011).

## Nothing works after a `git pull`
```bash
cd ~/.config/nvim
:Lazy clean
:Lazy restore
```
If still broken, delete `~/.local/share/nvim` (plugin install dir, NOT the repo) and relaunch — lazy re-installs from the lockfile.
