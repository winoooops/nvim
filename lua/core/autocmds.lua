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

-- ========================================================================
-- Active-panel dimming: tint inactive windows with a slightly darker
-- Gruvbox Material background so the focused window stands out without
-- having to fight per-plugin border rendering. NormalNC is Neovim's
-- built-in "Normal, Non-Current" highlight group — updates instantly on
-- focus change, no autocmd timing needed.
--
-- Palette ref (Gruvbox Material medium):
--   bg0 (Normal)    : #282828   ← active window
--   bg0_hard        : #1d2021   ← inactive window (subtle, readable)
--   bg1             : #32302f   ← another option if #1d2021 feels too dark
-- ========================================================================
local function apply_panel_dim()
  vim.api.nvim_set_hl(0, "NormalNC",       { bg = "#1d2021" })
  vim.api.nvim_set_hl(0, "WinSeparator",   { fg = "#45403d", bg = "#1d2021" })
end

-- Re-apply on every colorscheme load so switching themes (or reloading
-- gruvbox-material) doesn't blow it away.
autocmd("ColorScheme", {
  group = augroup("PanelDim", { clear = true }),
  callback = apply_panel_dim,
})

-- Apply immediately for the current session.
apply_panel_dim()
