-- lua/plugins/editor.lua
-- Telescope, nvim-tree, oil, treesitter, rainbow-delimiters, autopairs,
-- Comment, indent-blankline, project.nvim.

return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
      extensions = {},
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- smart-open replaces telescope-frecency (no sqlite dep)
  {
    "danielfalk/smart-open.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    keys = { { "<leader>fs", "<cmd>Telescope smart_open<CR>" } },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
  },

  -- Project manager (kept from 2022)
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern", "lsp" },
        patterns = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" },
      })
      pcall(require("telescope").load_extension, "projects")
    end,
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      view = { width = 32 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    },
  },

  -- oil.nvim — edit the filesystem as a buffer
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "echasnovski/mini.icons" },
    keys = { { "-", "<cmd>Oil<CR>", desc = "Open parent directory" } },
    opts = {
      default_file_explorer = false, -- nvim-tree remains primary
      view_options = { show_hidden = true },
    },
  },

  -- Treesitter (pin to master; `main` branch is a rewrite without the classic configs API)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml", "markdown",
          "markdown_inline", "html", "css", "javascript", "typescript", "tsx",
          "python", "go", "rust", "regex",
        },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true },
      })
    end,
  },

  -- Rainbow delimiters (replaces archived ts-rainbow)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Comment.nvim with treesitter commentstring awareness
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" } },
  },
}
