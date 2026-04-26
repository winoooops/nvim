-- lua/plugins/completion.lua
-- blink.cmp replaces the entire 2022 nvim-cmp + cmp-buffer + cmp-path +
-- cmp-cmdline + cmp_luasnip + cmp-nvim-lsp + cmp-nvim-lua stack with a single plugin.

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
        -- Enter: accept the first suggestion even if you haven't navigated
        -- to it (`select_and_accept` picks the first item when nothing is
        -- selected). If the menu is empty, falls through to a normal newline.
        ["<CR>"] = { "select_and_accept", "fallback" },
        -- Tab: only used for snippet placeholders. When no snippet is active
        -- it falls through to vim's normal Tab → indent (2 spaces; see
        -- core/options.lua: expandtab/softtabstop/shiftwidth=2). Use <C-n> /
        -- <C-p> (or arrows) to navigate the completion menu.
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        -- preselect=true highlights the first item so <CR>'s
        -- `select_and_accept` has something to grab. auto_insert stays off
        -- so we don't pre-fill text into the buffer as you type.
        list = { selection = { preselect = true, auto_insert = false } },
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
