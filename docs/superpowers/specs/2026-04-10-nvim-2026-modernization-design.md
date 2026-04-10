# Neovim 2026 Modernization — Design Spec

**Date:** 2026-04-10
**Target repo:** `github.com/winoooops/nvim` (clone to `~/.config/nvim`)
**Baseline:** 2022-era Packer-based config from the same repo
**Outcome:** A modernized, cross-platform (macOS / Linux / WSL2) Neovim config optimized for an AI-agent-first workflow (Claude Code, Codex, Gemini).

---

## 1. Goals & Constraints

### Goals
1. Modernize the existing config to 2026 standards while preserving every keybinding from the 2022 version (muscle memory is sacred).
2. Optimize Neovim as a **diff-review cockpit** for agent-driven development, inspired by DHH's tmux + agents + nvim workflow.
3. Run identically across **macOS, native Linux, and WSL2 (inside WSL)**.
4. Single source of truth: one git repo is `~/.config/nvim` on every machine. Plugins are reproducible via `lazy-lock.json`.
5. Avoid frequent updates — pin to Neovim stable and only bump on explicit intent.

### Non-goals
- Native Windows Neovim (WSL2-only on Windows).
- Cursor-clone full IDE experience (avante.nvim deferred).
- Ghost-text inline completion (Copilot skipped, commented-out stub only).
- Any hand-maintained plugin state outside `lazy-lock.json`.

### Constraints
- **Neovim floor: 0.11.x** (stable as of 2026-04). Required by blink.cmp, snacks.nvim, and modern `vim.lsp` APIs.
- Preserve space as `<leader>` and `<localleader>`.
- Preserve every keybinding from `lua/keybindings.lua` in the old repo.
- No machine-local config files initially (YAGNI — add `lua/local.lua` only if a real divergence appears).

---

## 2. Architecture

### Directory layout

```
~/.config/nvim/
├── README.md                       # top-level INDEX (progressive disclosure)
├── CHANGELOG.md                    # what changed, for multi-machine sync visibility
├── init.lua                        # bootstrap lazy.nvim, load core/, load plugins/
├── stylua.toml                     # lua formatter config
├── lazy-lock.json                  # committed; pins all plugin versions
├── .gitignore                      # ignores plugin/, spell/, sessions/, undo/, shada/, .DS_Store, lua/local.lua
├── docs/
│   ├── install.md                  # per-OS install (macOS, Linux, WSL2)
│   ├── keybindings.md              # full keybinding cheatsheet
│   ├── troubleshooting.md          # clipboard, fonts, mason, LSP issues
│   ├── updating.md                 # update nvim + plugins safely
│   └── superpowers/specs/          # design specs (this file lives here)
└── lua/
    ├── core/
    │   ├── README.md               # what each file does
    │   ├── options.lua             # ← was basic.lua
    │   ├── keymaps.lua             # ← was keybindings.lua (preserved + extended)
    │   ├── autocmds.lua            # autoreload, yank highlight, filetype tweaks
    │   └── platform.lua            # WSL2/macOS/Linux detection + clipboard
    └── plugins/
        ├── README.md               # plugin domain index with status
        ├── init.lua                # lazy.nvim bootstrap + setup
        ├── ui.lua                  # tokyonight, catppuccin, lualine, bufferline, snacks dashboard/notify, which-key, mini.icons
        ├── editor.lua              # telescope, nvim-tree, oil.nvim, treesitter, rainbow-delimiters, autopairs, Comment.nvim, indent-blankline, project.nvim
        ├── git.lua                 # gitsigns, diffview.nvim
        ├── lsp.lua                 # mason, mason-lspconfig, nvim-lspconfig
        ├── completion.lua          # blink.cmp + LuaSnip + friendly-snippets
        ├── format.lua              # conform.nvim
        ├── lint.lua                # nvim-lint
        ├── terminal.lua            # toggleterm (vertical default, named terminals)
        └── ai.lua                  # CodeCompanion.nvim + commented copilot.lua
```

### Loading order in `init.lua`
1. `require("core.platform")` — set platform globals first (needed by clipboard)
2. `require("core.options")` — vim.opt settings
3. `require("core.keymaps")` — all keybindings
4. `require("core.autocmds")` — autocmds (including agent-friendly autoreload)
5. `require("plugins")` — lazy.nvim bootstrap + plugin specs
6. `pcall(require, "local")` — optional machine-local overrides (gitignored, not created by default)

---

## 3. Plugin Modernization Map

### Package manager
| Old | New | Rationale |
|---|---|---|
| packer.nvim | **lazy.nvim** | Packer archived. Lazy.nvim is the de facto standard (LazyVim, kickstart, NvChad). Gives us `lazy-lock.json` for cross-machine reproducibility. |

### LSP & tooling
| Old | New | Rationale |
|---|---|---|
| nvim-lsp-installer | **mason.nvim** + **mason-lspconfig** | lsp-installer deprecated into mason upstream. |
| `sumneko_lua` | **lua_ls** | Upstream rename. |
| null-ls.nvim | **conform.nvim** (format) + **nvim-lint** (lint) | null-ls archived 2023. conform is the standard formatter runner. |
| `vim.lsp.buf.formatting_sync()` | `vim.lsp.buf.format()` via conform | Old API removed in nvim 0.11. |

### Completion
| Old | New | Rationale |
|---|---|---|
| nvim-cmp + cmp-buffer + cmp-path + cmp-cmdline + cmp_luasnip + cmp-nvim-lsp + cmp-nvim-lua | **blink.cmp** | Rust-backed, single plugin replaces cmp + all sources, ~10x faster, canonical in 2026. |
| LuaSnip + friendly-snippets | **keep** (native blink.cmp integration) | Still the snippet gold standard. |

### UI
| Old | New | Rationale |
|---|---|---|
| vim-airline + airline-themes | **lualine.nvim** | Pure Lua, faster, native integration with modern plugins. |
| vim-signify | **removed** | gitsigns.nvim already covers it. |
| alpha-nvim | **snacks.nvim dashboard** | Consolidated into snacks. |
| nvim-notify | **snacks.nvim notifier** | Consolidated into snacks. |
| bufferline.nvim | **keep** | Still great, no replacement needed. |
| tokyonight, gruvbox, nord, doom-one, everforest, nightfox | **tokyonight** (primary) + **catppuccin** (alt) | Trim from 6 to 2. Tokyonight is the user's current default (per `colorscheme.lua`). |
| nvim-web-devicons | **mini.icons** | Lighter, auto-fallback, part of mini.nvim suite. |
| nvim-ts-rainbow | **rainbow-delimiters.nvim** | ts-rainbow archived. |
| vim-highlighturl | **removed** | Treesitter handles URL highlighting. |
| markdown-preview.nvim + glow.nvim | **markview.nvim** | Inline markdown rendering in-buffer — useful for reading AI replies and docs. |

### Editor
| Old | New | Rationale |
|---|---|---|
| nvim-tree | **keep**, plus add **oil.nvim** | oil.nvim lets you edit the filesystem as a buffer (rename files with `cw`, delete with `dd`). Big productivity win, complements nvim-tree without replacing it. |
| telescope.nvim | **keep** | Still best-in-class fuzzy finder. |
| telescope-media-files | **keep** | Niche but still maintained. |
| telescope-frecency + sqlite.lua | **smart-open.nvim** | Removes the painful sqlite native dep (especially on WSL2). |
| Comment.nvim + nvim-ts-context-commentstring | **keep** | Still nicer than native `gc` for embedded filetypes. |
| windwp/nvim-autopairs | **keep** | Still the standard. |
| lukas-reineke/indent-blankline.nvim (ibl) | **keep** | Already modern. |
| ahmedkhalf/project.nvim | **keep** | Still maintained. |
| moll/vim-bbye | **snacks.nvim bufdelete** | Consolidated. |
| popup.nvim | **removed** | No longer required. |
| nvim-lua/plenary.nvim | **keep** | Transitive dep of many plugins. |

### Git
| Old | New | Rationale |
|---|---|---|
| gitsigns.nvim | **keep** | Best-in-class inline hunks. |
| lazygit (via toggleterm) | **keep** — preserved `<leader>g` binding | Already correct from 2022 config. |
| *(none)* | **diffview.nvim** ← NEW | The plugin for reviewing multi-file agent changes. Critical for the agent-first workflow. |

### Terminal
| Old | New | Rationale |
|---|---|---|
| toggleterm.nvim | **keep**, default layout = **vertical split** | User-selected. Named persistent terminals for each CLI agent. |

### AI / agents (new domain)
| Plugin | Status | Rationale |
|---|---|---|
| **CodeCompanion.nvim** | enabled | In-editor chat + inline edits. Supports Anthropic, OpenAI, Ollama adapters. Most mature Claude-native plugin in 2026. |
| **copilot.lua** + blink-cmp-copilot | **commented out** | User opted out of ghost text. Stub left in `ai.lua` with a one-line note for future enablement. |
| avante.nvim | **not included** | Overlaps with CodeCompanion; deferred. |
| github/copilot.vim | **removed** | Replaced by commented-out copilot.lua stub. |

### Net plugin count
- Old: ~35 plugins
- New: ~28 plugins (with more features; snacks.nvim and mini.icons each consolidate 5–6 old plugins)

---

## 4. Keybindings

### Preservation (verbatim from 2022 config)
All of the following are preserved exactly:

**Leader:** `<space>` (both leader and localleader).

**Window splits:** `<leader>sw`, `<leader>sW`, `<leader>cw`, `<leader>cW`.
**Window nav:** `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`.
**Resize:** `<leader>lS`, `<leader>nS`, `<leader>ls`, `<leader>ns`.
**Buffer cycle:** `<S-k>` next, `<S-j>` prev, `<leader>w` delete, `<leader>W` delete-all.
**Tabs:** `<leader><leader>k`, `<leader><leader>j`, `<leader><leader>n`, `<leader><leader>w`.
**Visual indent:** `<` and `>` (stay in visual).
**Visual move:** `J` / `K` in `x` mode.
**Insert-mode nav:** `<C-h/j/k/l/w/e/b/a/i>`.
**Save + format:** `<leader>s` — migrated to `vim.lsp.buf.format({ async = false })` then `:w` (old `formatting_sync` API is gone).
**Tree toggle:** `<leader>e` → `:NvimTreeToggle`.
**Netrw:** `<leader>E` → `:Explore`.
**Telescope:** `<leader>f` find files, `<leader>fp` projects.
**Telescope frecency:** `<leader>fs` — repointed from telescope-frecency to **smart-open.nvim** (identical trigger).
**Lazygit:** `<leader>g` — unchanged.

### New bindings (additive, no collisions with preserved set)

**AI chat (`<leader>a*` namespace):**
- `<leader>ac` — CodeCompanion chat toggle
- `<leader>aa` — CodeCompanion actions palette
- `<leader>ae` — CodeCompanion inline edit (visual mode)
- `<leader>an` — new CodeCompanion chat

**AI CLI terminals (`<leader>t*` namespace):**
- `<leader>tc` — toggle "claude" terminal (persistent)
- `<leader>tx` — toggle "codex" terminal (persistent)
- `<leader>tg` — toggle "gemini" terminal (persistent)
- `<leader>tt` — toggle scratch shell terminal
- `<leader>tv` — force vertical layout
- `<leader>th` — force horizontal layout
- `<leader>tf` — force floating layout

**Diff / review (`<leader>d*` namespace):**
- `<leader>dv` — `:DiffviewOpen`
- `<leader>dc` — `:DiffviewClose`
- `<leader>dh` — `:DiffviewFileHistory`

**Git hunks (via gitsigns):**
- `]h` / `[h` — next/prev hunk
- `<leader>hp` — preview hunk
- `<leader>hs` — stage hunk
- `<leader>hu` — undo stage hunk
- `<leader>hr` — reset hunk

**LSP (via lspconfig on_attach):**
- `gd`, `gD`, `gr`, `gi`, `K`, `<leader>rn`, `<leader>ca`, `[d`, `]d`, `<leader>dl`

Full cheatsheet lives in `docs/keybindings.md`.

---

## 5. AI Agent Integration (DHH Cockpit)

### Mental model
Neovim is the **diff-review cockpit**. CLI agents (Claude, Codex, Gemini) do most of the typing. CodeCompanion handles in-buffer quick questions. The user's core loop:

1. Open nvim in project root.
2. `<leader>tc` → spawn Claude in vertical split, issue a task.
3. Claude edits files → nvim auto-reloads via `FileChangedShellPost` autocmd, notify toast fires.
4. `<leader>dv` → diffview shows all agent changes across files.
5. `<leader>g` → lazygit to stage/discard hunks selectively.
6. `<leader>ac` → CodeCompanion for quick inline questions on reviewed diffs.
7. `<leader>tx` → Codex for a second opinion on a tricky change.

### CodeCompanion adapters
Configured in `lua/plugins/ai.lua`:
- **Primary:** Anthropic (Claude Sonnet 4.6 / Opus 4.6), reads `ANTHROPIC_API_KEY` from env.
- **Secondary:** OpenAI (GPT-5.x), reads `OPENAI_API_KEY` from env.
- **Fallback:** Ollama localhost for offline work.

### Agent-friendly autocmds (`lua/core/autocmds.lua`)
```lua
vim.opt.autoread = true
vim.opt.updatetime = 250  -- faster CursorHold for external-change detection

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() !~ '\\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk — reloaded", vim.log.levels.WARN)
  end,
})
```

### Toggleterm configuration
- Default direction: `vertical`
- Default size: `vim.o.columns * 0.4`
- Named terminals: `claude`, `codex`, `gemini`, each wrapping its CLI binary, each with a fixed `id` so `ToggleTerm 1/2/3` reopens the same instance.
- Per-binding layout overrides via `<leader>tv/th/tf`.

---

## 6. Cross-Platform Sync

### Sync mechanism
- The repo **is** `~/.config/nvim` on every machine.
- Initial clone: `git clone git@github.com:winoooops/nvim.git ~/.config/nvim`
- First launch: lazy.nvim bootstraps itself, reads `lazy-lock.json`, installs pinned versions.
- Update flow on primary machine: `:Lazy sync` → commit `lazy-lock.json` → push.
- Update flow on other machines: `git pull && :Lazy restore`.

### Platform detection (`lua/core/platform.lua`)
```lua
local M = {}
local uname = vim.loop.os_uname()
M.is_mac     = uname.sysname == "Darwin"
M.is_wsl     = vim.env.WSL_DISTRO_NAME ~= nil
M.is_linux   = uname.sysname == "Linux" and not M.is_wsl
M.is_windows = uname.sysname:match("Windows") ~= nil
return M
```

### Clipboard strategy
| Platform | Provider | Config |
|---|---|---|
| macOS | builtin `pbcopy`/`pbpaste` | Auto-detected, no action. |
| Linux (native) | `xclip` or `wl-copy` | Auto-detected if installed. |
| **WSL2** | **`win32yank.exe`** | Manually wired in `platform.lua` — sets `vim.g.clipboard` to shell out to `win32yank.exe`. Required so yanks flow to Windows clipboard. |

Install command for `win32yank.exe` documented in `docs/install.md` and `docs/troubleshooting.md`.

### Fonts
- **JetBrainsMono Nerd Font** on all machines.
- macOS: `brew install --cask font-jetbrains-mono-nerd-font`
- Linux: download to `~/.local/share/fonts/`, run `fc-cache -fv`
- WSL2: install the font in **Windows Terminal** (Windows-side), set profile font to `JetBrainsMono Nerd Font`. The font lives in Windows, WSL just emits characters.

### External dependency checklist (in `docs/install.md`)
**Required everywhere:**
- Neovim ≥ 0.11
- git, make, unzip, gcc
- ripgrep, fd-find
- JetBrainsMono Nerd Font
- Node.js (for LSP servers installed via mason)
- Python 3 + pynvim

**WSL2 only:**
- `win32yank.exe`

**For the AI layer:**
- `claude` CLI (`npm i -g @anthropic-ai/claude-code`)
- `codex` CLI
- `gemini` CLI (optional)
- Env vars: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` (for CodeCompanion)

### `.gitignore`
```
plugin/
spell/
sessions/
undo/
shada/
.DS_Store
lua/local.lua
```

(`plugin/packer_compiled.lua` from the old repo is removed entirely; lazy.nvim writes nothing to `plugin/`.)

### Machine-local overrides
Not included initially. If a real divergence appears, `lua/local.lua` (gitignored) loaded via `pcall(require, "local")` at the bottom of `init.lua`. **YAGNI — do not create the file during initial implementation.**

### Neovim version policy
- Pin to Neovim stable (currently 0.11.x as of 2026-04-10).
- No auto-update. User bumps manually, maybe twice a year.
- Plugins are frozen by `lazy-lock.json` between bumps — no plugin drift from unrelated nvim updates.

---

## 7. Documentation Structure (Progressive Disclosure)

### Top-level `README.md` = Index only
- 1-paragraph overview ("Cross-platform Neovim config optimized for agent-driven development.")
- Quick start: one install line per OS, then `nvim`.
- Links to:
  - `docs/install.md` (full install)
  - `docs/keybindings.md` (cheatsheet)
  - `docs/troubleshooting.md`
  - `docs/updating.md`
  - `lua/core/README.md` (core architecture)
  - `lua/plugins/README.md` (plugin domain index)
  - `CHANGELOG.md`

**Top-level README never grows beyond ~60 lines.** All detail lives in linked sub-docs.

### `lua/core/README.md`
Table: one row per file in `core/`, one sentence describing it.

### `lua/plugins/README.md`
Table of plugin domains with status markers, e.g.:
```
| File           | Status | Plugins                                        |
|----------------|--------|------------------------------------------------|
| ui.lua         | ✅     | tokyonight, catppuccin, lualine, snacks, ...   |
| ai.lua         | ✅     | CodeCompanion (copilot.lua commented out)      |
| completion.lua | ✅     | blink.cmp, LuaSnip, friendly-snippets          |
...
```
Each plugin change updates **only this file**, never the top-level README.

### `CHANGELOG.md`
Keep-a-changelog format. Entries added on every sync-worthy change:
```
## [Unreleased]
### Added
- CodeCompanion Ollama fallback adapter

## [2026-04-10] Initial 2026 modernization
### Added / Changed / Removed ...
```
When the user `git pull`s on machine B, they read CHANGELOG to know what's new.

### `docs/keybindings.md`
Grouped tables: Windows, Buffers, Tabs, Telescope, LSP, Git, AI, Terminal, Diff. Derived from `lua/core/keymaps.lua` and plugin-scoped bindings. Updated alongside any keybinding change.

### `docs/install.md`
Per-OS install instructions, copy-pasteable code blocks: deps, font, nvim, clone.

### `docs/troubleshooting.md`
Common issues: WSL2 clipboard not working → install win32yank; icons look broken → Nerd Font not set in terminal emulator; mason LSP fails → Node.js missing; etc.

### `docs/updating.md`
Upgrade flow for nvim itself (per OS) and for plugins (`:Lazy sync` → commit lock → push → pull on other machines → `:Lazy restore`).

---

## 8. Error Handling & Failure Modes

- **Missing external CLI (`claude`/`codex`/`gemini`)**: toggleterm command simply fails with a readable error inside the terminal pane. Not fatal to nvim.
- **Missing API keys**: CodeCompanion surfaces a clear error on first request; other subsystems unaffected.
- **lazy-lock.json out of sync**: `:Lazy restore` aligns the local install to the lockfile. If corrupted, delete and `:Lazy sync` regenerates.
- **Mason LSP install failure**: individual LSP servers fail loudly; other servers keep working. Documented in troubleshooting.
- **win32yank missing on WSL2**: clipboard falls back to `unnamedplus` without Windows-side sync; documented as a known issue with fix steps.
- **Nerd Font missing**: icons render as tofu/squares. Documented as the first item in troubleshooting.
- **Old Neovim version (< 0.11)**: lazy.nvim bootstrap fails with a clear version error at first launch. User must upgrade per `docs/updating.md`.

---

## 9. Testing Strategy

Neovim configs don't get "unit tested" in the traditional sense, but we can verify:

1. **Fresh-clone smoke test**: clone the repo into a temp `XDG_CONFIG_HOME` on each target OS, launch nvim, confirm lazy.nvim bootstraps cleanly, `:checkhealth` reports no errors beyond expected ones (mason Node.js if not installed, etc.).
2. **Keybinding parity test**: manually walk the preserved keybinding list from Section 4 on a fresh install and confirm each works identically to the 2022 config.
3. **Cross-platform smoke**: run the fresh-clone smoke test on all three target OSes (macOS, native Linux, WSL2) before declaring the migration complete.
4. **Agent workflow test**: trigger each AI integration — `<leader>tc` opens Claude terminal, `<leader>ac` opens CodeCompanion chat and gets a response, an external `echo 'test' >> file.lua` while nvim is open triggers the auto-reload notification.
5. **Lockfile reproducibility**: on a second machine, `git pull && :Lazy restore` produces identical plugin versions to the first machine.

---

## 10. Open Questions / Deferred Decisions

- **avante.nvim**: deferred. Revisit if CodeCompanion proves insufficient for inline-edit flows.
- **MCP client plugins**: still early in 2026; revisit when a clear winner emerges.
- **Local LLM via Ollama**: Ollama adapter wired into CodeCompanion but not enabled by default. User enables when they install Ollama.
- **`lua/local.lua`**: not created initially. Add if and when a real cross-machine divergence appears.
