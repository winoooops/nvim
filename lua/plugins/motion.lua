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
      -- typing the target text; labels appear progressively.
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      -- Treesitter jump: jumps by syntax node (function, block, argument...).
      -- Useful inside large files. Replaces vim's default `S` (substitute line).
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },
}
