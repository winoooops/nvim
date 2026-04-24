-- lua/plugins/ui.lua
-- Theme, statusline, bufferline, dashboard, notifier, which-key, icons.
-- snacks.nvim consolidates dashboard + notifier + bufdelete (replaces
-- alpha-nvim + nvim-notify + vim-bbye from 2022).

return {
  -- Colorscheme (primary)
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "medium"        -- "hard" | "medium" | "soft"
      vim.g.gruvbox_material_foreground = "material"      -- "material" | "mix" | "original"
      vim.g.gruvbox_material_better_performance = 1
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },

  -- Colorschemes (alternates — switch via :colorscheme <name>)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      transparent = false,
      styles = { sidebars = "transparent" },
    },
  },
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
        theme = "gruvbox-material",
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
      layout = {
        width   = { min = 30 },      -- a bit wider columns than default
        spacing = 4,
      },
      -- All icons are Material Design Icons (nf-md-*) from Nerd Fonts —
      -- chosen because they render consistently in JetBrainsMono Nerd Font.
      spec = {
        -- Single actions (bound via plain `opts` with no desc; label here)
        { "<leader>e",         desc  = "Toggle nvim-tree",      icon = "󰙅 " },
        { "<leader>E",         desc  = "Netrw explore",         icon = "󰉋 " },
        { "<leader>g",         desc  = "Lazygit",               icon = "󰊢 " },
        { "<leader>w",         desc  = "Delete buffer",         icon = "󰅖 " },
        { "<leader>W",         desc  = "Delete all buffers",    icon = "󰩺 " },
        { "<leader>Y",         desc  = "Yazi at cwd",           icon = "󰝰 " },
        { "<leader>?",         desc  = "Buffer-local keymaps",  icon = "󰘥 " },

        -- Group prefixes (keys with sub-keymaps)
        { "<leader>a",         group = "AI / Agents",           icon = "󰚩 " },
        { "<leader>c",         group = "Close / Code",          icon = "󰅗 " },
        { "<leader>d",         group = "Diff / Diagnostic",     icon = "󰦓 " },
        { "<leader>f",         group = "Find / Files",          icon = "󰍉 " },
        { "<leader>h",         group = "Hunks (git)",           icon = "󰊢 " },
        { "<leader>l",         group = "Resize (wider)",        icon = "󰞘 " },
        { "<leader>n",         group = "Resize (narrower)",     icon = "󰞗 " },
        { "<leader>r",         group = "Rename",                icon = "󰑕 " },
        { "<leader>s",         group = "Split / Save",          icon = "󱂬 " },
        { "<leader>t",         group = "Terminals",             icon = "󰆍 " },
        { "<leader>y",         group = "Yazi",                  icon = "󰉋 " },
        { "<leader><leader>",  group = "Tab",                   icon = "󰓩 " },
      },
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
