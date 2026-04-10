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
