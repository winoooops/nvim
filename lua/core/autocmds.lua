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
  vim.api.nvim_set_hl(0, "NormalNC",            { bg = "#1d2021" })
  -- Inactive border: visible neutral gray (was #45403d, basically invisible).
  vim.api.nvim_set_hl(0, "WinSeparator",        { fg = "#7c6f64", bg = "#1d2021" })
  -- Active border: vivid blue matching tmux's pane-active-border. Used via the
  -- WinEnter/WinLeave winhl swap below — the focused window's border lights up
  -- regardless of whether the buffer is a terminal (toggleterm's shade_terminals
  -- repaints backgrounds and defeats NormalNC, but borders are unaffected).
  vim.api.nvim_set_hl(0, "ActiveWinSeparator",  { fg = "#89b4fa", bg = "NONE" })
end

-- Re-apply on every colorscheme load so switching themes (or reloading
-- gruvbox-material) doesn't blow it away.
autocmd("ColorScheme", {
  group = augroup("PanelDim", { clear = true }),
  callback = apply_panel_dim,
})

-- Apply immediately for the current session.
apply_panel_dim()

-- Swap the focused window's WinSeparator → ActiveWinSeparator. This is the
-- ONLY reliable visual indicator of focus when terminal buffers are involved
-- — NormalNC dimming gets overridden by toggleterm's shade_terminals.
local active_border_grp = augroup("ActiveBorder", { clear = true })
autocmd({ "WinEnter", "BufWinEnter" }, {
  group = active_border_grp,
  callback = function()
    vim.opt_local.winhl:append("WinSeparator:ActiveWinSeparator")
  end,
})
autocmd("WinLeave", {
  group = active_border_grp,
  callback = function()
    -- Strip our override; the window goes back to inheriting WinSeparator.
    local cur = vim.opt_local.winhl:get()
    cur["WinSeparator"] = nil
    vim.opt_local.winhl = cur
  end,
})

-- ========================================================================
-- Terminal bell → desktop notification
-- ========================================================================
-- Claude Code (preferredNotifChannel=terminal_bell) emits a BEL when it
-- wants attention. libvterm absorbs the BEL inside :terminal so it never
-- reaches the outer tmux/Ghostty stack — but nvim does fire `User TermBell`
-- on every terminal-buffer bell, regardless of `belloff`. Bridge that
-- straight to notify-send. (Sibling/non-nvim tmux panes are covered by
-- the alert-bell hook in ~/.tmux.conf.)
autocmd("User", {
  pattern = "TermBell",
  group = augroup("TermBellNotify", { clear = true }),
  callback = function()
    vim.fn.jobstart({
      "notify-send",
      "-a", "Claude Code",
      "-i", "utilities-terminal",
      "Claude Code",
      "needs your attention",
    }, { detach = true })
  end,
})
