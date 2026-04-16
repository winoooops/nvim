# Changelog

All notable changes to this Neovim config. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

When you `git pull` on a second machine, read this file to see what's new since your last sync.

## [Unreleased]

### Changed
- **nvim-treesitter**: migrated from the archived `master` branch to the `main` branch. The legacy `require("nvim-treesitter.configs").setup()` API is replaced with the new `opts = { ensure_installed = {...} }` style. Highlighting, indentation, and incremental selection are now handled by Neovim's built-in treesitter support (0.10+). This fixes a crash (`attempt to call method 'range' (a nil value)`) triggered by markview.nvim on Neovim 0.12+.
- **nvim-tree**: added `actions.open_file.window_picker.exclude` to skip terminal and special buffers. Files opened from nvim-tree no longer land in toggleterm panels (Claude, Codex, etc.).

### Known follow-ups
- Install libsqlite3-dev on each machine if using `smart-open.nvim` for scoring (optional — telescope `find_files` works without it).

## [2026-04-10] Initial 2026 modernization

Complete rewrite of the 2022 Packer-based config into a 2026 agent-first layout. The 2022 files are preserved in `legacy-2022/` for reference, and the pre-modernization commit is tagged `v2022-legacy`.

### Added
- `lazy.nvim` as package manager with committed `lazy-lock.json` for cross-machine reproducibility
- `mason.nvim` + `mason-lspconfig` replacing `nvim-lsp-installer`
- `blink.cmp` replacing `nvim-cmp` + 6 `cmp-*` source plugins
- `conform.nvim` (format) + `nvim-lint` (lint) replacing `null-ls.nvim`
- `snacks.nvim` consolidating dashboard, notifier, bufdelete (replaces alpha-nvim, nvim-notify, vim-bbye)
- `lualine.nvim` replacing `vim-airline`
- `mini.icons` replacing `nvim-web-devicons`
- `rainbow-delimiters.nvim` replacing archived `nvim-ts-rainbow`
- `oil.nvim` — edit the filesystem as a buffer (alongside nvim-tree)
- `smart-open.nvim` replacing `telescope-frecency` (no sqlite native dep required for basic use)
- `markview.nvim` for inline markdown rendering (reading AI replies in-buffer)
- `diffview.nvim` for multi-file diff review — the agent cockpit's heart
- `toggleterm.nvim` with **vertical split default** and named persistent terminals for `claude`, `codex`, `gemini`, `lazygit`, and a scratch shell
- **CodeCompanion.nvim** for in-editor AI chat with Anthropic / OpenAI / Ollama adapters
- Agent-friendly auto-reload: `FocusGained` / `CursorHold` `checktime` + `FileChangedShellPost` notification so agent-made file edits surface instantly
- Platform detection module (`lua/core/platform.lua`) with WSL2 `win32yank` clipboard wiring
- Progressive-disclosure docs: top-level index `README.md`, per-directory READMEs in `lua/core/` and `lua/plugins/`, and `docs/install.md`, `docs/keybindings.md`, `docs/troubleshooting.md`, `docs/updating.md`
- This `CHANGELOG.md`
- `catppuccin` as an alternate colorscheme
- ~~Pinned `nvim-treesitter` to `branch = "master"`~~ — migrated to `main` branch in a later update (see `[Unreleased]` above).

### Changed
- Directory layout: `lua/basic.lua`, `lua/plugins.lua`, `lua/keybindings.lua` → `lua/core/options.lua`, `lua/core/keymaps.lua`, `lua/core/autocmds.lua`, `lua/core/platform.lua`, and `lua/plugins/<domain>.lua`
- `<leader>s` save-and-format migrated from deprecated `vim.lsp.buf.formatting_sync()` to `conform.format() + :w`
- `<leader>fs` repointed from `telescope-frecency` to `smart-open.nvim` (same trigger, no sqlite dep required)
- `sumneko_lua` → `lua_ls` (upstream rename)
- `tsserver` → `ts_ls` (upstream rename)
- `smartcase` changed from `false` to `true` (modern default)
- `cmdheight` lowered from 2 to 1 (snacks notifier handles spillover)

### Removed
- `packer.nvim` (archived)
- `nvim-lsp-installer` (deprecated into mason)
- `null-ls.nvim` (archived)
- `nvim-cmp` + `cmp-buffer` + `cmp-path` + `cmp-cmdline` + `cmp_luasnip` + `cmp-nvim-lsp` + `cmp-nvim-lua` (replaced by blink.cmp)
- `vim-airline` + `vim-airline-themes`
- `vim-signify` (covered by gitsigns)
- `alpha-nvim` (covered by snacks.nvim)
- `nvim-notify` (covered by snacks.nvim)
- `vim-bbye` (covered by snacks.nvim)
- `popup.nvim` (no longer needed)
- `nvim-ts-rainbow` (archived)
- `vim-highlighturl` (treesitter handles this)
- `markdown-preview.nvim`, `glow.nvim` (replaced by markview.nvim)
- `neoformat` (replaced by conform.nvim)
- `telescope-frecency`, `sqlite.lua` at top-level (smart-open handles the use case)
- `telescope-media-files.nvim` (niche, can re-add if needed)
- `github/copilot.vim` (replaced by commented-out `copilot.lua` stub in `lua/plugins/ai.lua`)
- Colorschemes trimmed from 6 (tokyonight, gruvbox, nord, doom-one, everforest, nightfox) to 2 (tokyonight + catppuccin)

### Preserved (muscle memory)
- Every keybinding from the 2022 `lua/keybindings.lua`
- `<leader>` = space
- Tokyonight as default theme
- 2-space indent, expandtab, smartindent
- `<leader>g` → lazygit (still there, now via toggleterm named terminal)
