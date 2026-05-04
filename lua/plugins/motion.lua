-- lua/plugins/motion.lua
-- flash.nvim — label-based jump motion. Replaces the older `s{ab}` (vim-sneak)
-- workflow with a treesitter-aware overlay: type `s`, then a few characters,
-- and tiny labels appear on every match — pick a label letter to jump.

return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- Plain jump: in normal/visual/operator-pending. Type `s` then start
      -- typing the target text; labels appear progressively. Searches
      -- forward from the cursor (and wraps at EOF).
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({ search = { forward = true, wrap = false } })
        end,
        desc = "Flash jump forward",
      },
      -- Backward sneak: same UX as `s`, but search only goes UP (toward
      -- start of buffer). Mirrors the vim-sneak `s`/`S` directional pair.
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({ search = { forward = false, wrap = false } })
        end,
        desc = "Flash jump backward",
      },
      -- Treesitter jump (syntax-node selection). Moved off `S` so `S`
      -- can be the directional inverse of `s`. Use `<leader>js` for the
      -- structural motion when you want it.
      {
        "<leader>js",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash treesitter (jump by syntax node)",
      },
    },
  },
}
