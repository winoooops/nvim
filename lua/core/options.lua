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
