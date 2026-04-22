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
-- <leader>f is now a PREFIX, not an action — no more ambiguity with <leader>fg etc.
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files(require("telescope.themes").get_ivy())
end, opts)
map("n", "<leader>fp", "<cmd>Telescope projects<CR>", opts)
-- <leader>fs was telescope-frecency in 2022; now points to smart-open.nvim
map("n", "<leader>fs", "<cmd>Telescope smart_open<CR>", opts)
-- Fuzzy search text INSIDE files (ripgrep-backed live grep)
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
-- Fuzzy search the word under the cursor across project
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", opts)
-- Fuzzy search inside the current buffer only
map("n", "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<CR>", opts)
-- Open buffer list (fuzzy search open buffers)
map("n", "<leader>fl", "<cmd>Telescope buffers<CR>", opts)

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
