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
