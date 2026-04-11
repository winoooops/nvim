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
      -- Enabled modules
      dashboard = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      bufdelete = { enabled = true },
      quickfile = { enabled = true },
      words = { enabled = true },
      -- Explicitly disabled — silences :checkhealth snacks false-positive
      -- errors that fire from submodule health checks regardless of enabled state.
      image = { enabled = false },
      statuscolumn = { enabled = false }, -- lualine owns status
      bigfile = { enabled = false },
      explorer = { enabled = false }, -- nvim-tree is primary
      input = { enabled = false },
      picker = { enabled = false }, -- telescope is primary
      scope = { enabled = false },
      scroll = { enabled = false },
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
