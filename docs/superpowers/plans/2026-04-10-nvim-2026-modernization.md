# Neovim 2026 Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernize the 2022-era `winoooops/nvim` config into a 2026 agent-first Neovim config that syncs identically across macOS, Linux, and WSL2 via `lazy-lock.json`.

**Architecture:** Flat two-layer module tree (`lua/core/` and `lua/plugins/`), lazy.nvim for package management with committed lockfile, mason for LSPs, blink.cmp for completion, conform+nvim-lint for format/lint, snacks.nvim for UI consolidation, CodeCompanion for in-editor AI chat, toggleterm (vertical-split default) for CLI agent terminals, diffview.nvim for reviewing agent-made changes. Progressive-disclosure docs with per-directory READMEs linked from a top-level index.

**Tech Stack:** Neovim ≥ 0.11, Lua 5.1, lazy.nvim, mason.nvim, nvim-lspconfig, blink.cmp, conform.nvim, nvim-lint, snacks.nvim, telescope.nvim, treesitter, gitsigns.nvim, diffview.nvim, toggleterm.nvim, CodeCompanion.nvim, tokyonight + catppuccin themes.

**Spec:** `docs/superpowers/specs/2026-04-10-nvim-2026-modernization-design.md`

**Verification model:** Nvim configs don't have traditional unit tests. Each task's "test" step is either (a) launching nvim and running a specific command to verify behavior, (b) running `:checkhealth <plugin>`, or (c) inspecting a file or command output. Treat these verification steps as RED/GREEN equivalents.

---

## Task 1: Bootstrap the repo in ~/.config/nvim

**Files:**
- Create: `~/.config/nvim/.git/` (via git init)
- Create: `~/.config/nvim/legacy-2022/` (archive of old config)
- Preserve: `~/.config/nvim/docs/superpowers/` (spec + plan already exist)

- [ ] **Step 1: Back up the spec and plan (they already exist in `~/.config/nvim/docs/superpowers/`)**

```bash
cp -r ~/.config/nvim/docs /tmp/nvim-docs-backup
ls /tmp/nvim-docs-backup/superpowers/specs/
ls /tmp/nvim-docs-backup/superpowers/plans/
```
Expected: see the spec file and this plan file listed.

- [ ] **Step 2: Clone the legacy repo into a temp location**

```bash
rm -rf /tmp/nvim-legacy
git clone https://github.com/winoooops/nvim.git /tmp/nvim-legacy
ls /tmp/nvim-legacy
```
Expected: see `init.lua`, `lua/`, `plugin/`, `.git/`.

- [ ] **Step 3: Clear `~/.config/nvim` except our docs, then move the cloned repo in**

```bash
# Save docs, wipe dir, restore docs into cloned repo
rm -rf ~/.config/nvim
mv /tmp/nvim-legacy ~/.config/nvim
mkdir -p ~/.config/nvim/docs
cp -r /tmp/nvim-docs-backup/superpowers ~/.config/nvim/docs/superpowers
ls ~/.config/nvim
ls ~/.config/nvim/docs/superpowers/specs
```
Expected: repo files present AND `docs/superpowers/specs/2026-04-10-nvim-2026-modernization-design.md` present.

- [ ] **Step 4: Move the 2022 files into `legacy-2022/` for reference**

```bash
cd ~/.config/nvim
mkdir -p legacy-2022
git mv init.lua legacy-2022/init.lua
git mv lua legacy-2022/lua
git mv plugin legacy-2022/plugin
ls
```
Expected: `legacy-2022/`, `docs/`, `.git/` remain at root. No top-level `init.lua` or `lua/` yet.

- [ ] **Step 5: Create the new empty directory skeleton**

```bash
cd ~/.config/nvim
mkdir -p lua/core lua/plugins docs
touch lua/core/.gitkeep lua/plugins/.gitkeep
find . -maxdepth 2 -type d -not -path './.git*' | sort
```
Expected output includes: `./docs`, `./legacy-2022`, `./lua`, `./lua/core`, `./lua/plugins`.

- [ ] **Step 6: Commit the archive + skeleton**

```bash
cd ~/.config/nvim
git add -A
git commit -m "chore: archive 2022 config to legacy-2022/, scaffold new lua/core and lua/plugins"
git log --oneline | head -5
```
Expected: commit created. No pre-existing commit is touched.

---

## Task 2: Write `.gitignore` and `stylua.toml`

**Files:**
- Create: `~/.config/nvim/.gitignore`
- Create: `~/.config/nvim/stylua.toml`

- [ ] **Step 1: Create `.gitignore`**

```gitignore
# lazy.nvim compiles here — regenerated on every launch
plugin/packer_compiled.lua

# Machine-local state
spell/
sessions/
undo/
shada/

# OS cruft
.DS_Store
Thumbs.db

# Machine-local override (YAGNI — not created by default, but ignored preemptively)
lua/local.lua

# Editor temp
*.swp
*.swo
```

- [ ] **Step 2: Create `stylua.toml`**

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

- [ ] **Step 3: Commit**

```bash
cd ~/.config/nvim
git add .gitignore stylua.toml
git commit -m "chore: add .gitignore and stylua.toml"
```

---

## Task 3: Write `lua/core/platform.lua`

**Files:**
- Create: `~/.config/nvim/lua/core/platform.lua`

- [ ] **Step 1: Write the platform detection module**

```lua
-- lua/core/platform.lua
-- Detects the OS and exposes booleans used by other modules
-- (primarily for clipboard setup on WSL2).
local M = {}

local uname = vim.loop.os_uname()
local sysname = uname.sysname or ""

M.is_mac = sysname == "Darwin"
M.is_wsl = vim.env.WSL_DISTRO_NAME ~= nil
M.is_linux = sysname == "Linux" and not M.is_wsl
M.is_windows = sysname:match("Windows") ~= nil

-- Wire WSL2 clipboard to win32yank.exe so yanks flow to Windows clipboard.
-- Requires `win32yank.exe` on PATH (installed via docs/install.md).
if M.is_wsl then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

return M
```

- [ ] **Step 2: Verify it loads (no nvim yet — just Lua syntax check)**

```bash
cd ~/.config/nvim
lua -e "loadfile('lua/core/platform.lua')()" 2>&1 || echo "Lua not installed — will verify via nvim later"
```
Expected: no syntax errors, or a "Lua not installed" fallback. Syntax errors fail the task.

- [ ] **Step 3: Commit**

```bash
cd ~/.config/nvim
git add lua/core/platform.lua
git commit -m "feat(core): add platform detection and WSL2 clipboard wiring"
```

---

## Task 4: Write `lua/core/options.lua` (was `basic.lua`)

**Files:**
- Create: `~/.config/nvim/lua/core/options.lua`

- [ ] **Step 1: Write the options module**

```lua
-- lua/core/options.lua
-- vim.opt settings. Ported from the 2022 lua/basic.lua with 2026 updates.
local opt = vim.opt

-- Encoding
opt.fileencoding = "utf-8"

-- UI
opt.termguicolors = true
opt.cursorline = true
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cmdheight = 1 -- was 2 in 2022; 1 is modern default, snacks.nvim notifier handles spillover
opt.pumheight = 10
opt.showmode = false -- lualine shows mode

-- Files / backup (same as 2022 — we trust git + autosave)
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- Indentation
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.softtabstop = 2
opt.shiftwidth = 2
opt.tabstop = 2

-- Search
opt.ignorecase = true
opt.smartcase = true -- changed from 2022 (false) — modern default
opt.hlsearch = true
opt.incsearch = true

-- Wrapping / movement
opt.whichwrap:append("b,s,<,>,[,],h,l")
opt.wrap = false

-- Completion
opt.wildmenu = true
opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Mouse
opt.mouse = "a"

-- External file changes (critical for agent workflow — see autocmds.lua)
opt.autoread = true
opt.updatetime = 250 -- down from default 4000 for faster CursorHold + external-change detection

-- Timing
opt.timeoutlen = 500

-- Clipboard — platform.lua handles WSL2; macOS/Linux native get unnamedplus here.
opt.clipboard = "unnamedplus"

-- Leader is set in keymaps.lua before any mapping is declared.
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add lua/core/options.lua
git commit -m "feat(core): add options.lua ported from 2022 basic.lua with 2026 updates"
```

---

## Task 5: Write `lua/core/keymaps.lua` (preserved bindings + new namespaces)

**Files:**
- Create: `~/.config/nvim/lua/core/keymaps.lua`

- [ ] **Step 1: Write the keymaps module**

```lua
-- lua/core/keymaps.lua
-- Keybindings ported verbatim from 2022 lua/keybindings.lua
-- plus new <leader>a/t/d/h namespaces for AI, terminals, diffview, git hunks.
-- Plugin-specific keymaps (telescope, LSP on_attach, gitsigns, CodeCompanion)
-- live in their respective plugin spec files.

-- Leader — must be set before any mapping
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ========================================================================
-- Preserved from 2022 (muscle memory — DO NOT CHANGE)
-- ========================================================================

-- Window splits
map("n", "<leader>sw", ":vsp<CR>", opts)
map("n", "<leader>sW", ":sp<CR>", opts)
map("n", "<leader>cw", "<C-w>c", opts)
map("n", "<leader>cW", "<C-w>o", opts)

-- Window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Window resize
map("n", "<leader>lS", ":resize +2<CR>", opts)
map("n", "<leader>nS", ":resize -2<CR>", opts)
map("n", "<leader>ls", ":vertical resize +2<CR>", opts)
map("n", "<leader>ns", ":vertical resize -2<CR>", opts)

-- Tree toggle (nvim-tree — plugin loaded in plugins/editor.lua)
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
map("n", "<leader>E", ":Explore<CR>", opts)

-- Buffer cycling (preserved — Shift-j/k)
map("n", "<S-k>", ":bnext<CR>", opts)
map("n", "<S-j>", ":bprevious<CR>", opts)
-- Buffer delete via snacks.nvim bufdelete (replaces vim-bbye's :Bdelete)
map("n", "<leader>w", function() Snacks.bufdelete() end, opts)
map("n", "<leader>W", function() Snacks.bufdelete.all() end, opts)

-- Tab nav
map("n", "<leader><leader>k", ":tabn<CR>", opts)
map("n", "<leader><leader>j", ":tabp<CR>", opts)
map("n", "<leader><leader>n", ":tabnew<CR>", opts)
map("n", "<leader><leader>w", ":tabc<CR>", opts)

-- Visual indent keeps selection
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Visual move lines (x-mode)
map("x", "J", ":m '>+1<CR>gv=gv", opts)
map("x", "K", ":m '<-2<CR>gv=gv", opts)

-- Insert-mode navigation (preserved from 2022)
map("i", "<C-h>", "<C-O>h", opts)
map("i", "<C-l>", "<C-O>l", opts)
map("i", "<C-j>", "<C-O>j", opts)
map("i", "<C-k>", "<C-O>k", opts)
map("i", "<C-w>", "<C-O>w", opts)
map("i", "<C-e>", "<C-O>e", opts)
map("i", "<C-b>", "<C-O>b", opts)
map("i", "<C-a>", "<C-O>A", opts)
map("i", "<C-i>", "<C-O>I", opts)

-- Save + format — migrated from deprecated vim.lsp.buf.formatting_sync()
map("n", "<leader>s", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = false, lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = false })
  end
  vim.cmd("write")
end, opts)

-- Telescope (plugin loaded in plugins/editor.lua)
map("n", "<leader>f", function()
  require("telescope.builtin").find_files(require("telescope.themes").get_ivy())
end, opts)
map("n", "<leader>fp", "<cmd>Telescope projects<CR>", opts)
-- <leader>fs was telescope-frecency in 2022; now points to smart-open.nvim
map("n", "<leader>fs", "<cmd>Telescope smart_open<CR>", opts)

-- Lazygit (preserved — opens lazygit terminal from plugins/terminal.lua)
map("n", "<leader>g", function() _G._LAZYGIT_TOGGLE() end, opts)

-- ========================================================================
-- New 2026 bindings
-- ========================================================================

-- AI chat (CodeCompanion) — <leader>a* namespace
map("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", opts)
map("n", "<leader>aa", "<cmd>CodeCompanionActions<CR>", opts)
map("n", "<leader>an", "<cmd>CodeCompanionChat<CR>", opts)
map("v", "<leader>ae", ":CodeCompanion<CR>", opts)

-- AI CLI terminals — <leader>t* namespace (bindings live in plugins/terminal.lua
-- so we only declare the layout-override ones here; the named terminal bindings
-- are created when the toggleterm plugin spec loads.)

-- Diff review — <leader>d* namespace
map("n", "<leader>dv", "<cmd>DiffviewOpen<CR>", opts)
map("n", "<leader>dc", "<cmd>DiffviewClose<CR>", opts)
map("n", "<leader>dh", "<cmd>DiffviewFileHistory %<CR>", opts)
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add lua/core/keymaps.lua
git commit -m "feat(core): port 2022 keymaps and add a/t/d namespaces for AI, terminals, diffview"
```

---

## Task 6: Write `lua/core/autocmds.lua`

**Files:**
- Create: `~/.config/nvim/lua/core/autocmds.lua`

- [ ] **Step 1: Write the autocmds module**

```lua
-- lua/core/autocmds.lua
-- Autocmds, including the agent-friendly file-reload logic that makes
-- Neovim a safe cockpit for Claude/Codex/Gemini CLIs editing files
-- underneath an open buffer.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ========================================================================
-- Agent-friendly auto-reload
-- ========================================================================
-- When a coding agent rewrites a file on disk while it's open in nvim,
-- we want to see the change immediately. `autoread` plus a `checktime`
-- trigger on FocusGained/BufEnter/CursorHold catches ~all cases.
local reload_grp = augroup("AgentAutoReload", { clear = true })

autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = reload_grp,
  pattern = "*",
  command = "if mode() !~ '\\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif",
})

-- Notify when a file was changed on disk and nvim reloaded it.
autocmd("FileChangedShellPost", {
  group = reload_grp,
  callback = function(args)
    local name = vim.fn.fnamemodify(args.file, ":t")
    vim.notify(("File changed on disk, reloaded: %s"):format(name), vim.log.levels.WARN, {
      title = "Agent edit detected",
    })
  end,
})

-- ========================================================================
-- Quality-of-life
-- ========================================================================
-- Highlight yanked region briefly.
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Strip trailing whitespace on save for code files.
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.tsx", "*.jsx", "*.go", "*.rs", "*.md" },
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Resize splits when the terminal window is resized.
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  command = "tabdo wincmd =",
})
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add lua/core/autocmds.lua
git commit -m "feat(core): add autocmds with agent-friendly auto-reload on FileChangedShellPost"
```

---

## Task 7: Write `init.lua` + minimal `lua/plugins/init.lua` (lazy.nvim bootstrap)

**Files:**
- Create: `~/.config/nvim/init.lua`
- Create: `~/.config/nvim/lua/plugins/init.lua`

- [ ] **Step 1: Write `init.lua`**

```lua
-- init.lua — entry point
-- Load order matters: platform before options (clipboard),
-- keymaps before plugins (so leader is set), autocmds can load anywhere.

require("core.platform")
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- lazy.nvim bootstrap + plugin specs
require("plugins")

-- Optional machine-local overrides (gitignored, YAGNI — not created by default)
pcall(require, "local")
```

- [ ] **Step 2: Write `lua/plugins/init.lua` with lazy.nvim self-install**

```lua
-- lua/plugins/init.lua
-- lazy.nvim bootstrap. This is the only place that knows about lazy.
-- Plugin specs are imported from sibling files in lua/plugins/.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    error("lazy.nvim install failed")
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Each sibling file below returns a lazy.nvim plugin spec (or list of specs).
    { import = "plugins.ui" },
    { import = "plugins.editor" },
    { import = "plugins.git" },
    { import = "plugins.terminal" },
    { import = "plugins.lsp" },
    { import = "plugins.completion" },
    { import = "plugins.format" },
    { import = "plugins.lint" },
    { import = "plugins.ai" },
  },
  install = { colorscheme = { "tokyonight", "default" } },
  checker = { enabled = false }, -- don't auto-check for updates; user runs :Lazy sync manually
  change_detection = { notify = false },
})
```

- [ ] **Step 3: Create empty stub files for every imported module (so lazy doesn't error)**

```bash
cd ~/.config/nvim
for f in ui editor git terminal lsp completion format lint ai; do
  echo "return {}" > "lua/plugins/$f.lua"
done
rm lua/plugins/.gitkeep lua/core/.gitkeep 2>/dev/null || true
ls lua/plugins/
```
Expected: ui.lua, editor.lua, git.lua, terminal.lua, lsp.lua, completion.lua, format.lua, lint.lua, ai.lua, init.lua.

- [ ] **Step 4: First launch — verify lazy.nvim bootstraps**

```bash
nvim --headless "+qa" 2>&1 | tee /tmp/nvim-first-launch.log
cat /tmp/nvim-first-launch.log
```
Expected: either empty output or a harmless `Installing lazy.nvim` line. No Lua errors. If you see errors, fix them before proceeding.

- [ ] **Step 5: Verify lazy.nvim directory was created**

```bash
ls ~/.local/share/nvim/lazy/lazy.nvim/README.md
```
Expected: path exists.

- [ ] **Step 6: Commit**

```bash
cd ~/.config/nvim
git add init.lua lua/plugins/
git commit -m "feat: bootstrap lazy.nvim and empty plugin spec stubs"
```

---

## Task 8: Write `lua/plugins/ui.lua` (theme, statusline, snacks, which-key)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/ui.lua`

- [ ] **Step 1: Replace stub with full UI plugin spec**

```lua
-- lua/plugins/ui.lua
-- Theme, statusline, bufferline, dashboard, notifier, which-key, icons.
-- snacks.nvim consolidates dashboard + notifier + bufdelete (replaces
-- alpha-nvim + nvim-notify + vim-bbye from 2022).

return {
  -- Colorscheme (primary)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      styles = { sidebars = "transparent" },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Colorscheme (alternate — switch via :colorscheme catppuccin)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = { flavour = "mocha" },
  },

  -- Icons
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "slant",
      },
    },
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer local keymaps" },
    },
  },

  -- snacks.nvim — dashboard + notifier + bufdelete + picker + terminal utils
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      bufdelete = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false }, -- lualine owns status
      words = { enabled = true },
    },
  },

  -- Inline markdown rendering (for reading AI replies and docs)
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    ft = { "markdown", "codecompanion" },
    dependencies = { "echasnovski/mini.icons" },
  },
}
```

- [ ] **Step 2: Launch nvim and sync plugins**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -30
```
Expected: lazy installs tokyonight, catppuccin, mini.icons, lualine, bufferline, which-key, snacks, markview. No errors. `lazy-lock.json` is created.

- [ ] **Step 3: Launch nvim interactively and visually verify**

Run: `nvim`
Check: tokyonight theme applied, lualine at the bottom, bufferline at the top. Close with `:qa`.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/ui.lua lazy-lock.json
git commit -m "feat(plugins): add UI layer (tokyonight, lualine, bufferline, snacks, which-key, markview)"
```

---

## Task 9: Write `lua/plugins/editor.lua`

**Files:**
- Modify: `~/.config/nvim/lua/plugins/editor.lua`

- [ ] **Step 1: Replace stub with editor plugin spec**

```lua
-- lua/plugins/editor.lua
-- Telescope, nvim-tree, oil, treesitter, rainbow-delimiters, autopairs,
-- Comment, indent-blankline, project.nvim.

return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
      extensions = {},
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- smart-open replaces telescope-frecency (no sqlite dep)
  {
    "danielfalk/smart-open.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    keys = { { "<leader>fs", "<cmd>Telescope smart_open<CR>" } },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },

  -- Project manager (kept from 2022)
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern", "lsp" },
        patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" },
      })
      pcall(require("telescope").load_extension, "projects")
    end,
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      view = { width = 32 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    },
  },

  -- oil.nvim — edit the filesystem as a buffer
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "echasnovski/mini.icons" },
    keys = { { "-", "<cmd>Oil<CR>", desc = "Open parent directory" } },
    opts = {
      default_file_explorer = false, -- nvim-tree remains primary
      view_options = { show_hidden = true },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml", "markdown",
          "markdown_inline", "html", "css", "javascript", "typescript", "tsx",
          "python", "go", "rust", "regex",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
      })
    end,
  },

  -- Rainbow delimiters (replaces archived ts-rainbow)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Comment.nvim with treesitter commentstring awareness
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" } },
  },
}
```

- [ ] **Step 2: Sync plugins**

```bash
nvim --headless "+Lazy! sync" "+TSUpdateSync" "+qa" 2>&1 | tail -20
```
Expected: clean sync, treesitter parsers install.

- [ ] **Step 3: Verify telescope and nvim-tree work**

Run: `nvim` then `<leader>f` — telescope find_files opens. `<leader>e` — nvim-tree opens. `:qa`.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/editor.lua lazy-lock.json
git commit -m "feat(plugins): add editor layer (telescope, tree, oil, treesitter, rainbow, autopairs, comment, indent)"
```

---

## Task 10: Write `lua/plugins/git.lua`

**Files:**
- Modify: `~/.config/nvim/lua/plugins/git.lua`

- [ ] **Step 1: Replace stub with git plugin spec**

```lua
-- lua/plugins/git.lua
-- gitsigns.nvim for inline hunks, diffview.nvim for reviewing
-- multi-file agent changes (the cockpit's heart).
-- Lazygit is spawned from plugins/terminal.lua via the preserved <leader>g.

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function m(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end
        m("n", "]h", gs.next_hunk, "Next hunk")
        m("n", "[h", gs.prev_hunk, "Prev hunk")
        m("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        m("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        m("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        m("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        m("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        m("n", "<leader>hd", gs.diffthis, "Diff this")
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      use_icons = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_mixed" },
        file_history = { layout = "diff2_horizontal" },
      },
    },
  },
}
```

- [ ] **Step 2: Sync plugins**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
```
Expected: gitsigns and diffview install cleanly.

- [ ] **Step 3: Verify inside a git repo**

```bash
cd ~/.config/nvim
nvim init.lua
```
Then `:DiffviewOpen` — should open the diffview UI (even if there's no diff, the pane opens). `:qa`.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/git.lua lazy-lock.json
git commit -m "feat(plugins): add gitsigns and diffview for agent diff review"
```

---

## Task 11: Write `lua/plugins/terminal.lua` (toggleterm with named AI terminals)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/terminal.lua`

- [ ] **Step 1: Replace stub with terminal plugin spec**

```lua
-- lua/plugins/terminal.lua
-- toggleterm.nvim configured for the DHH cockpit:
-- default layout = vertical split, named persistent terminals for
-- claude/codex/gemini/lazygit + a scratch shell.

return {
  "akinsho/toggleterm.nvim",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    "<leader>tc", "<leader>tx", "<leader>tg", "<leader>tt",
    "<leader>tv", "<leader>th", "<leader>tf", "<leader>g",
  },
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "vertical",
      size = function(term)
        if term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        elseif term.direction == "horizontal" then
          return math.floor(vim.o.lines * 0.3)
        end
        return 20
      end,
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      persist_mode = true,
      close_on_exit = true,
      float_opts = { border = "rounded" },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- Named persistent terminals. Each has a unique count so toggling
    -- reopens the same instance.
    local claude = Terminal:new({ cmd = "claude", hidden = true, direction = "vertical", count = 11 })
    local codex = Terminal:new({ cmd = "codex", hidden = true, direction = "vertical", count = 12 })
    local gemini = Terminal:new({ cmd = "gemini", hidden = true, direction = "vertical", count = 13 })
    local scratch = Terminal:new({ hidden = true, direction = "vertical", count = 14 })
    local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", count = 15 })

    -- Expose lazygit toggle globally so keymaps.lua can call it.
    _G._LAZYGIT_TOGGLE = function() lazygit:toggle() end

    local function kset(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
    end

    kset("<leader>tc", function() claude:toggle() end, "Toggle Claude CLI")
    kset("<leader>tx", function() codex:toggle() end, "Toggle Codex CLI")
    kset("<leader>tg", function() gemini:toggle() end, "Toggle Gemini CLI")
    kset("<leader>tt", function() scratch:toggle() end, "Toggle scratch shell")

    -- Layout overrides — act on the last-active toggleterm
    kset("<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", "Toggle vertical term")
    kset("<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", "Toggle horizontal term")
    kset("<leader>tf", "<cmd>ToggleTerm direction=float<CR>", "Toggle float term")

    -- Easy exit from terminal insert mode
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function()
        local o = { buffer = 0, silent = true }
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], o)
        vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], o)
        vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], o)
        vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], o)
        vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], o)
      end,
    })
  end,
}
```

- [ ] **Step 2: Sync plugins**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
```
Expected: toggleterm installs cleanly.

- [ ] **Step 3: Manual verification**

Run: `nvim`. Press `<leader>tt` — a vertical terminal opens on the right (40% width). Press `<esc>` to leave insert, `<leader>tt` again to hide. Press `<leader>g` — lazygit attempts to open (may error if lazygit isn't installed, that's OK for now). `:qa`.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/terminal.lua lazy-lock.json
git commit -m "feat(plugins): add toggleterm with vertical default and named AI CLI terminals"
```

---

## Task 12: Write `lua/plugins/lsp.lua` (mason + lspconfig)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/lsp.lua`

- [ ] **Step 1: Replace stub with LSP plugin spec**

```lua
-- lua/plugins/lsp.lua
-- mason + mason-lspconfig + nvim-lspconfig.
-- Replaces the 2022 nvim-lsp-installer setup.

local function on_attach(_, bufnr)
  local function m(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  m("gd", vim.lsp.buf.definition, "Go to definition")
  m("gD", vim.lsp.buf.declaration, "Go to declaration")
  m("gr", vim.lsp.buf.references, "References")
  m("gi", vim.lsp.buf.implementation, "Implementation")
  m("K", vim.lsp.buf.hover, "Hover docs")
  m("<leader>rn", vim.lsp.buf.rename, "Rename")
  m("<leader>ca", vim.lsp.buf.code_action, "Code action")
  m("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
  m("]d", vim.diagnostic.goto_next, "Next diagnostic")
  m("<leader>dl", vim.diagnostic.open_float, "Diagnostic line")
end

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",        -- was sumneko_lua in 2022
          "pyright",
          "ts_ls",         -- was tsserver
          "gopls",
          "rust_analyzer",
          "jsonls",
          "yamlls",
          "bashls",
          "html",
          "cssls",
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- blink.cmp sets its own capabilities in plugins/completion.lua

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim", "Snacks" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        ts_ls = {},
        gopls = {},
        rust_analyzer = {},
        jsonls = {},
        yamlls = {},
        bashls = {},
        html = {},
        cssls = {},
      }

      for name, cfg in pairs(servers) do
        cfg.on_attach = on_attach
        cfg.capabilities = capabilities
        lspconfig[name].setup(cfg)
      end

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}
```

- [ ] **Step 2: Sync plugins and install LSP servers**

```bash
nvim --headless "+Lazy! sync" "+MasonUpdate" "+qa" 2>&1 | tail -20
```
Expected: mason installs, lspconfig installs. LSP servers download lazily on first use (don't force them all now).

- [ ] **Step 3: Verify with a Lua file**

```bash
cd ~/.config/nvim
nvim lua/core/options.lua
```
Wait ~5 seconds. Type `:LspInfo` — should show lua_ls attached (after mason auto-installs it). `:qa`.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/lsp.lua lazy-lock.json
git commit -m "feat(plugins): add mason + lspconfig with lua_ls, pyright, ts_ls, gopls, rust_analyzer"
```

---

## Task 13: Write `lua/plugins/completion.lua` (blink.cmp)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/completion.lua`

- [ ] **Step 1: Replace stub with blink.cmp spec**

```lua
-- lua/plugins/completion.lua
-- blink.cmp replaces the entire 2022 nvim-cmp + cmp-buffer + cmp-path +
-- cmp-cmdline + cmp_luasnip + cmp-nvim-lsp stack with a single plugin.

return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  {
    "saghen/blink.cmp",
    version = "*", -- release tag — avoids needing Rust toolchain
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        list = { selection = { preselect = false, auto_insert = false } },
      },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
}
```

- [ ] **Step 2: Sync plugins**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -20
```
Expected: blink.cmp and LuaSnip install. Release version avoids Rust build.

- [ ] **Step 3: Verify completion works**

```bash
cd ~/.config/nvim
nvim lua/core/options.lua
```
Enter insert mode, type `vim.op` — expect a completion menu showing `opt`, `options`, etc. Press `<esc>:qa!`.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/completion.lua lazy-lock.json
git commit -m "feat(plugins): add blink.cmp + LuaSnip (replaces 2022 nvim-cmp stack)"
```

---

## Task 14: Write `lua/plugins/format.lua` (conform.nvim)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/format.lua`

- [ ] **Step 1: Replace stub with conform spec**

```lua
-- lua/plugins/format.lua
-- conform.nvim replaces null-ls for formatting.
-- <leader>s in keymaps.lua calls conform.format() directly.

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format", "ruff_fix" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      go = { "gofmt" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
    },
    default_format_opts = { lsp_format = "fallback" },
  },
}
```

- [ ] **Step 2: Sync**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
```

- [ ] **Step 3: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/format.lua lazy-lock.json
git commit -m "feat(plugins): add conform.nvim for formatting (replaces null-ls)"
```

---

## Task 15: Write `lua/plugins/lint.lua` (nvim-lint)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/lint.lua`

- [ ] **Step 1: Replace stub with nvim-lint spec**

```lua
-- lua/plugins/lint.lua
-- nvim-lint replaces null-ls for linting.

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      python = { "ruff" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      sh = { "shellcheck" },
      markdown = { "markdownlint" },
    }
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
      callback = function() lint.try_lint() end,
    })
  end,
}
```

- [ ] **Step 2: Sync**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
```

- [ ] **Step 3: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/lint.lua lazy-lock.json
git commit -m "feat(plugins): add nvim-lint for linting (replaces null-ls)"
```

---

## Task 16: Write `lua/plugins/ai.lua` (CodeCompanion + commented copilot stub)

**Files:**
- Modify: `~/.config/nvim/lua/plugins/ai.lua`

- [ ] **Step 1: Replace stub with AI plugin spec**

```lua
-- lua/plugins/ai.lua
-- CodeCompanion.nvim for in-editor chat and inline edits.
-- Adapters: Anthropic (primary), OpenAI (secondary), Ollama (fallback).
-- copilot.lua is intentionally commented out — uncomment if you want
-- ghost-text inline suggestions in addition to chat.

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = { "<leader>ac", "<leader>aa", "<leader>an", "<leader>ae" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = { api_key = "ANTHROPIC_API_KEY" },
            schema = {
              model = { default = "claude-sonnet-4-6" },
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = { api_key = "OPENAI_API_KEY" },
          })
        end,
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = { model = { default = "llama3.1:latest" } },
          })
        end,
      },
      display = {
        chat = {
          window = { layout = "vertical", width = 0.45 },
        },
      },
    },
  },

  -- ===================================================================
  -- Copilot ghost text — DISABLED by design. Uncomment if you want
  -- inline grey-text suggestions via GitHub Copilot. Requires a Copilot
  -- subscription and `:Copilot auth` on first launch.
  -- ===================================================================
  --[[
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<Tab>" } },
      panel = { enabled = false },
    },
  },
  --]]
}
```

- [ ] **Step 2: Sync**

```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -10
```
Expected: CodeCompanion installs. Copilot does NOT install (it's commented).

- [ ] **Step 3: Verify CodeCompanion loads without crashing**

```bash
nvim -c "CodeCompanionChat" -c "sleep 1" -c "qa" 2>&1 | tail -5
```
Expected: no error output. If `ANTHROPIC_API_KEY` isn't set, the chat window still opens — errors surface on first send, not on load.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/nvim
git add lua/plugins/ai.lua lazy-lock.json
git commit -m "feat(plugins): add CodeCompanion with Anthropic/OpenAI/Ollama adapters; copilot stubbed"
```

---

## Task 17: Write top-level `README.md` (progressive-disclosure index)

**Files:**
- Create: `~/.config/nvim/README.md`

- [ ] **Step 1: Write the index README**

```markdown
# Neovim 2026

Cross-platform Neovim config optimized for agent-driven development (Claude Code, Codex, Gemini). Syncs identically across macOS, native Linux, and WSL2 via `lazy-lock.json`.

## Quick start

```bash
git clone https://github.com/winoooops/nvim.git ~/.config/nvim
nvim
```

First launch bootstraps lazy.nvim and installs all plugins from the lockfile.

## Requirements

- Neovim ≥ 0.11
- git, make, unzip, gcc, ripgrep, fd, Node.js, Python 3
- A Nerd Font (JetBrainsMono Nerd Font recommended)

Full per-OS install: [docs/install.md](docs/install.md)

## Documentation

| Doc | Purpose |
|---|---|
| [docs/install.md](docs/install.md) | Per-OS install, fonts, clipboard bridge |
| [docs/keybindings.md](docs/keybindings.md) | Full keybinding cheatsheet |
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
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add README.md
git commit -m "docs: add top-level README index"
```

---

## Task 18: Write `lua/core/README.md` and `lua/plugins/README.md`

**Files:**
- Create: `~/.config/nvim/lua/core/README.md`
- Create: `~/.config/nvim/lua/plugins/README.md`

- [ ] **Step 1: Write `lua/core/README.md`**

```markdown
# lua/core

Core modules loaded by `init.lua` before any plugin. Each file has one responsibility.

| File | Responsibility |
|---|---|
| `platform.lua` | OS detection (macOS/Linux/WSL2) and WSL2 clipboard wiring via `win32yank.exe` |
| `options.lua` | All `vim.opt` settings — indentation, search, clipboard, splits, etc. |
| `keymaps.lua` | Global keybindings. Preserved 2022 set + new `<leader>a/t/d` namespaces |
| `autocmds.lua` | Agent-friendly auto-reload, yank highlight, trailing whitespace strip, split resize |

## Load order

```
platform → options → keymaps → autocmds → plugins
```

Platform must load first because it sets `vim.g.clipboard` for WSL2 before `options.lua` reads `clipboard`. Keymaps must load before plugins so `<leader>` is set before plugin `keys = {...}` specs are evaluated.

## Adding a new core module

1. Create the file in `lua/core/`
2. Add `require("core.<name>")` to `init.lua`
3. Update this README
```

- [ ] **Step 2: Write `lua/plugins/README.md`**

```markdown
# lua/plugins

One file per plugin domain. Each file returns a lazy.nvim plugin spec (or list of specs) and is imported from `lua/plugins/init.lua`.

## Domain index

| File | Status | Plugins |
|---|---|---|
| `init.lua` | ✅ | lazy.nvim bootstrap + domain imports |
| `ui.lua` | ✅ | tokyonight, catppuccin, mini.icons, lualine, bufferline, which-key, snacks.nvim, markview |
| `editor.lua` | ✅ | telescope, smart-open, project.nvim, nvim-tree, oil.nvim, treesitter, rainbow-delimiters, nvim-autopairs, Comment.nvim, indent-blankline |
| `git.lua` | ✅ | gitsigns, diffview.nvim |
| `terminal.lua` | ✅ | toggleterm (vertical default, named Claude/Codex/Gemini/lazygit terminals) |
| `lsp.lua` | ✅ | mason, mason-lspconfig, nvim-lspconfig (lua_ls, pyright, ts_ls, gopls, rust_analyzer, jsonls, yamlls, bashls, html, cssls) |
| `completion.lua` | ✅ | blink.cmp, LuaSnip, friendly-snippets |
| `format.lua` | ✅ | conform.nvim |
| `lint.lua` | ✅ | nvim-lint |
| `ai.lua` | ✅ CodeCompanion / ⏸ copilot.lua commented out | CodeCompanion.nvim (Anthropic/OpenAI/Ollama) |

## Status legend
- ✅ active
- ⏸ present but disabled (commented out)
- 🚧 in progress

## Adding a plugin

1. Open the file for the appropriate domain (or create a new file for a new domain).
2. Add the plugin spec.
3. Update this README's table.
4. Add an entry to `CHANGELOG.md` under `[Unreleased]`.
5. Run `:Lazy sync` and commit both the file and `lazy-lock.json`.

## Adding a plugin domain

1. Create `lua/plugins/<domain>.lua` returning a spec table.
2. Add `{ import = "plugins.<domain>" }` to `lua/plugins/init.lua`.
3. Add a row to this README.
```

- [ ] **Step 3: Commit**

```bash
cd ~/.config/nvim
git add lua/core/README.md lua/plugins/README.md
git commit -m "docs: add per-directory READMEs for core and plugins"
```

---

## Task 19: Write `docs/install.md`

**Files:**
- Create: `~/.config/nvim/docs/install.md`

- [ ] **Step 1: Write the install doc**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add docs/install.md
git commit -m "docs: add per-OS install guide"
```

---

## Task 20: Write `docs/keybindings.md`

**Files:**
- Create: `~/.config/nvim/docs/keybindings.md`

- [ ] **Step 1: Write the keybindings cheatsheet**

```markdown
# Keybindings

Leader key: `<space>`. All mappings use `<leader>` = space unless marked otherwise.

## Windows & splits
| Key | Action |
|---|---|
| `<leader>sw` | Vertical split |
| `<leader>sW` | Horizontal split |
| `<leader>cw` | Close current split |
| `<leader>cW` | Close all other splits |
| `<C-h/j/k/l>` | Navigate splits |
| `<leader>lS` / `<leader>nS` | Resize horizontal |
| `<leader>ls` / `<leader>ns` | Resize vertical |

## Buffers & tabs
| Key | Action |
|---|---|
| `<S-k>` | Next buffer |
| `<S-j>` | Previous buffer |
| `<leader>w` | Delete current buffer |
| `<leader>W` | Delete all buffers |
| `<leader><leader>k` | Next tab |
| `<leader><leader>j` | Prev tab |
| `<leader><leader>n` | New tab |
| `<leader><leader>w` | Close tab |

## File explorer
| Key | Action |
|---|---|
| `<leader>e` | Toggle nvim-tree |
| `<leader>E` | `:Explore` (netrw) |
| `-` | Open oil.nvim in parent directory |

## Telescope
| Key | Action |
|---|---|
| `<leader>f` | Find files |
| `<leader>fp` | Projects |
| `<leader>fs` | Smart-open (recency + frecency) |

## Save + format
| Key | Action |
|---|---|
| `<leader>s` | Format buffer (conform → LSP fallback) then save |

## LSP
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover docs |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `[d` / `]d` | Prev/next diagnostic |
| `<leader>dl` | Show diagnostic line |

## Git (gitsigns + lazygit + diffview)
| Key | Action |
|---|---|
| `]h` / `[h` | Next/prev hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Undo stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |
| `<leader>g` | Toggle lazygit (floating) |
| `<leader>dv` | Diffview open |
| `<leader>dc` | Diffview close |
| `<leader>dh` | Diffview file history |

## AI (CodeCompanion)
| Key | Action |
|---|---|
| `<leader>ac` | Toggle chat sidebar |
| `<leader>aa` | Actions palette |
| `<leader>an` | New chat |
| `<leader>ae` | Inline edit (visual mode) |

## Terminals (toggleterm, vertical default)
| Key | Action |
|---|---|
| `<leader>tc` | Toggle Claude CLI |
| `<leader>tx` | Toggle Codex CLI |
| `<leader>tg` | Toggle Gemini CLI |
| `<leader>tt` | Toggle scratch shell |
| `<leader>tv` | Vertical layout |
| `<leader>th` | Horizontal layout |
| `<leader>tf` | Floating layout |
| `<esc>` (in term) | Leave insert mode |
| `<C-hjkl>` (in term) | Navigate out of terminal |

## Visual mode
| Key | Action |
|---|---|
| `<` / `>` | Indent and stay in visual |
| `J` / `K` (x-mode) | Move selection down/up |

## Insert-mode navigation (preserved from 2022)
`<C-h/j/k/l>`, `<C-w>`, `<C-e>`, `<C-b>`, `<C-a>`, `<C-i>` — classic readline-like movement.
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add docs/keybindings.md
git commit -m "docs: add keybinding cheatsheet"
```

---

## Task 21: Write `docs/troubleshooting.md` and `docs/updating.md`

**Files:**
- Create: `~/.config/nvim/docs/troubleshooting.md`
- Create: `~/.config/nvim/docs/updating.md`

- [ ] **Step 1: Write `docs/troubleshooting.md`**

```markdown
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

## Neovim version too old (< 0.11)
Plugins like blink.cmp and snacks.nvim require 0.11+. Upgrade nvim — see [install.md § 1](install.md#1-neovim--011).

## Nothing works after a `git pull`
```bash
cd ~/.config/nvim
:Lazy clean
:Lazy restore
```
If still broken, delete `~/.local/share/nvim` (plugin install dir, NOT the repo) and relaunch — lazy re-installs from the lockfile.
```

- [ ] **Step 2: Write `docs/updating.md`**

```markdown
# Updating

## Update Neovim itself
Infrequent — maybe twice a year. Follow the install instructions again:
- macOS: `brew upgrade neovim`
- Debian/Ubuntu (PPA): `sudo apt update && sudo apt upgrade neovim`
- Arch: `sudo pacman -Syu neovim`

After upgrading, launch nvim once and run `:checkhealth` to confirm nothing broke.

## Update plugins

### On your primary machine
```bash
cd ~/.config/nvim
nvim +"Lazy sync" +qa
git add lazy-lock.json
git diff --cached lazy-lock.json | head -20  # sanity check
git commit -m "chore: bump plugins $(date +%Y-%m-%d)"
git push
```

Add an entry to `CHANGELOG.md` if any plugin was added, removed, or had a meaningful behavior change.

### On every other machine
```bash
cd ~/.config/nvim
git pull
nvim +"Lazy restore" +qa
```

`:Lazy restore` aligns the local plugin install to the exact commits in the lockfile. Much safer than `:Lazy sync`, which would pull latest upstream and create drift.

## Add or remove a plugin
1. Edit the appropriate `lua/plugins/<domain>.lua` file.
2. Update `lua/plugins/README.md` domain index.
3. Add an entry to `CHANGELOG.md` under `[Unreleased]`.
4. `:Lazy sync` to install/uninstall.
5. Commit the plugin file, the README, the CHANGELOG, and `lazy-lock.json` in one commit.
6. Push.

## Roll back a bad sync
```bash
cd ~/.config/nvim
git log --oneline lazy-lock.json | head -5
git checkout <prev-commit> -- lazy-lock.json
nvim +"Lazy restore" +qa
```

## Check what's different from origin
```bash
git fetch
git log --oneline HEAD..origin/main
```
```

- [ ] **Step 3: Commit both docs**

```bash
cd ~/.config/nvim
git add docs/troubleshooting.md docs/updating.md
git commit -m "docs: add troubleshooting and updating guides"
```

---

## Task 22: Write `CHANGELOG.md`

**Files:**
- Create: `~/.config/nvim/CHANGELOG.md`

- [ ] **Step 1: Write the changelog**

```markdown
# Changelog

All notable changes to this Neovim config. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

When you `git pull` on a second machine, read this file to see what's new since your last sync.

## [Unreleased]

## [2026-04-10] Initial 2026 modernization

Complete rewrite of the 2022 Packer-based config into a 2026 agent-first layout. The 2022 files are preserved in `legacy-2022/` for reference.

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
- `smart-open.nvim` replacing `telescope-frecency` (no sqlite native dep)
- `markview.nvim` for inline markdown rendering (reading AI replies in-buffer)
- `diffview.nvim` for multi-file diff review — the agent cockpit's heart
- `toggleterm.nvim` with **vertical split default** and named persistent terminals for `claude`, `codex`, `gemini`, `lazygit`, and a scratch shell
- **CodeCompanion.nvim** for in-editor AI chat with Anthropic / OpenAI / Ollama adapters
- Agent-friendly auto-reload: `FocusGained` / `CursorHold` `checktime` + `FileChangedShellPost` notification so agent-made file edits surface instantly
- Platform detection module (`lua/core/platform.lua`) with WSL2 `win32yank` clipboard wiring
- Progressive-disclosure docs: top-level index `README.md`, per-directory READMEs in `lua/core/` and `lua/plugins/`, and `docs/install.md`, `docs/keybindings.md`, `docs/troubleshooting.md`, `docs/updating.md`
- This `CHANGELOG.md`
- `catppuccin` as an alternate colorscheme

### Changed
- Directory layout: `lua/basic.lua`, `lua/plugins.lua`, `lua/keybindings.lua` → `lua/core/options.lua`, `lua/core/keymaps.lua`, `lua/core/autocmds.lua`, `lua/core/platform.lua`, and `lua/plugins/<domain>.lua`
- `<leader>s` save-and-format migrated from deprecated `vim.lsp.buf.formatting_sync()` to `conform.format() + :w`
- `<leader>fs` repointed from `telescope-frecency` to `smart-open.nvim` (same trigger, no sqlite dep)
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
- `telescope-frecency`, `sqlite.lua` (replaced by smart-open.nvim)
- `telescope-media-files.nvim` (niche, can re-add if needed)
- `github/copilot.vim` (replaced by commented-out `copilot.lua` stub in `lua/plugins/ai.lua`)
- Colorschemes trimmed from 6 (tokyonight, gruvbox, nord, doom-one, everforest, nightfox) to 2 (tokyonight + catppuccin)

### Preserved (muscle memory)
- Every keybinding from the 2022 `lua/keybindings.lua`
- `<leader>` = space
- Tokyonight as default theme
- 2-space indent, expandtab, smartindent
- `<leader>g` → lazygit (still there, now via toggleterm named terminal)
```

- [ ] **Step 2: Commit**

```bash
cd ~/.config/nvim
git add CHANGELOG.md
git commit -m "docs: add CHANGELOG with initial 2026 modernization entry"
```

---

## Task 23: Verification — fresh-clone smoke test script + first full launch

**Files:**
- Create: `~/.config/nvim/docs/superpowers/verify-smoke-test.sh` (standalone script — can be rerun on any machine)

- [ ] **Step 1: Write the smoke test script**

```bash
#!/usr/bin/env bash
# docs/superpowers/verify-smoke-test.sh
# Smoke tests this config in isolation, without touching the real
# ~/.config/nvim or ~/.local/share/nvim.
set -euo pipefail

TMP_CONFIG="$(mktemp -d)"
TMP_DATA="$(mktemp -d)"
TMP_STATE="$(mktemp -d)"
TMP_CACHE="$(mktemp -d)"

cleanup() { rm -rf "$TMP_CONFIG" "$TMP_DATA" "$TMP_STATE" "$TMP_CACHE"; }
trap cleanup EXIT

echo "==> Copying config to temp dir..."
cp -r ~/.config/nvim/. "$TMP_CONFIG/"

echo "==> Launching nvim with isolated XDG dirs..."
XDG_CONFIG_HOME="$(dirname "$TMP_CONFIG")" \
XDG_DATA_HOME="$TMP_DATA" \
XDG_STATE_HOME="$TMP_STATE" \
XDG_CACHE_HOME="$TMP_CACHE" \
nvim --headless \
  -c "autocmd User LazyDone ++once lua vim.schedule(vim.cmd.qa)" \
  -c "lua vim.defer_fn(vim.cmd.qa, 60000)" \
  2>&1 | tee "$TMP_CACHE/nvim.log"

if grep -i -E "error|E[0-9]+:" "$TMP_CACHE/nvim.log" | grep -v "no errors"; then
  echo "❌ Smoke test FAILED — see errors above"
  exit 1
fi

echo "✅ Smoke test passed"
```

- [ ] **Step 2: Make it executable and commit**

```bash
cd ~/.config/nvim
chmod +x docs/superpowers/verify-smoke-test.sh
git add docs/superpowers/verify-smoke-test.sh
git commit -m "test: add fresh-clone smoke test script"
```

- [ ] **Step 3: Run the full `:Lazy sync` interactively**

```bash
nvim
```
In nvim: `:Lazy sync` — wait until every plugin shows ✓. `:qa`.

- [ ] **Step 4: Run `:checkhealth` and scan for red**

```bash
nvim -c "checkhealth" -c "sleep 2" -c "qa" 2>&1 | tail -30
```
Expected: any CRITICAL/ERROR output is investigated. Yellow warnings about optional providers (Perl/Ruby) are OK.

- [ ] **Step 5: Walk the preserved keybinding list**

Run `nvim ~/.config/nvim/README.md` and manually verify:
- `<leader>e` opens nvim-tree, `<leader>e` closes it
- `<leader>f` opens telescope find_files
- `<leader>sw` vertical split
- `<leader>cw` close split
- `<C-h/j/k/l>` navigate splits
- `<S-j>` / `<S-k>` cycle buffers
- `<leader>s` saves + formats
- `<leader>tc` opens claude terminal (may error if `claude` CLI not installed — that's a PATH issue, not a config issue)
- `<leader>dv` opens diffview
- `:qa`

If any of these fail, fix in the appropriate file and recommit before proceeding.

- [ ] **Step 6: Commit the lockfile after full sync**

```bash
cd ~/.config/nvim
git add lazy-lock.json
git diff --cached lazy-lock.json | head -5
git commit -m "chore: pin initial plugin lockfile from first full sync" || echo "Nothing to commit (lockfile unchanged)"
```

---

## Task 24: Push to `winoooops/nvim` and tag the modernization

**Files:**
- None (git operations only)

- [ ] **Step 1: Verify repo state**

```bash
cd ~/.config/nvim
git status
git log --oneline | head -30
```
Expected: clean working tree, ~20+ commits from Tasks 1–23, legacy commits from the original repo still visible at the bottom of the log.

- [ ] **Step 2: Confirm push target with user**

**STOP AND ASK THE USER** before pushing. Show them:
- the branch name (`git branch --show-current`)
- the commit count (`git log --oneline origin/HEAD..HEAD | wc -l`)
- whether to push to `main` directly or to a feature branch like `modernization-2026`

Do not proceed until the user confirms the target.

- [ ] **Step 3: Push (after user confirmation)**

```bash
cd ~/.config/nvim
# Example — substitute the branch the user chose:
git push -u origin HEAD
```

- [ ] **Step 4: Tag the release**

```bash
cd ~/.config/nvim
git tag -a v2026.04.10 -m "2026 modernization: lazy.nvim, mason, blink.cmp, CodeCompanion, diffview, agent cockpit"
git push origin v2026.04.10
```

- [ ] **Step 5: Print final instructions for other machines**

Display to the user:
```
✅ Modernization complete.

To set up this config on another machine (macOS / Linux / WSL2):

  git clone https://github.com/winoooops/nvim.git ~/.config/nvim
  nvim

First launch bootstraps lazy.nvim and installs every plugin from lazy-lock.json.

To sync a new change from your primary machine:

  (primary)  cd ~/.config/nvim && nvim +"Lazy sync" +qa && git add lazy-lock.json && git commit -m "chore: bump plugins" && git push
  (others)   cd ~/.config/nvim && git pull && nvim +"Lazy restore" +qa

Read:
  - README.md                    — top-level index
  - docs/install.md              — per-OS setup (WSL2 clipboard, fonts, AI CLIs)
  - docs/keybindings.md          — full cheatsheet
  - docs/troubleshooting.md      — common issues
  - CHANGELOG.md                 — what changed
```

---

## Self-Review Notes

**Spec coverage check:** Every section of the spec maps to at least one task:
- §1 Goals & constraints → Task 1 (bootstrap), Task 7 (init.lua structure)
- §2 Architecture / directory layout → Tasks 1, 3-7 (core), Tasks 8-16 (plugins), Tasks 17-22 (docs)
- §3 Plugin modernization map → Tasks 8-16 (every swap has a dedicated step or sub-step)
- §4 Keybindings → Task 5 (preserved), Tasks 10/11/16 (plugin-scoped adds)
- §5 AI agent integration → Task 11 (toggleterm named terminals), Task 16 (CodeCompanion), Task 6 (autoreload autocmds)
- §6 Cross-platform sync → Task 3 (platform.lua), Task 19 (install.md), Task 21 (updating.md)
- §7 Progressive-disclosure docs → Tasks 17, 18, 19, 20, 21, 22
- §8 Error handling → Task 21 (troubleshooting.md)
- §9 Testing → Task 23 (smoke test + verification)
- §10 Open questions → Deferred items are noted but not coded

**Placeholder scan:** No TBDs, no "implement later", no "similar to above". Every step has complete code or exact commands.

**Type/name consistency:** `_G._LAZYGIT_TOGGLE` is defined in Task 11 and referenced in Task 5 — consistent. `Snacks.bufdelete` is used in Task 5's keymaps after snacks.nvim is added in Task 8 — correct order (keymaps.lua only runs after `require("plugins")` loads snacks). `codecompanion` commands (`CodeCompanionChat`, `CodeCompanionActions`) match between Task 5 keymaps and Task 16 plugin spec.

**One call-out for the executor:** Task 5 references `Snacks.bufdelete` as a global. snacks.nvim exposes this global when it loads (via `lazy = false` in Task 8), so the forward reference in keymaps.lua works as long as the plugin is loaded before any `<leader>w` keypress. This is fine because keymaps are just declared at startup and only resolved when the user presses the key.
