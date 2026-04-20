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
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = { show = { git = true } },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = true,
            exclude = {
              filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
      filters = { dotfiles = false },
      -- Agent-friendly refresh: watch the filesystem so edits from
      -- Claude/Codex/Gemini CLIs appear in the tree instantly, reload
      -- when focus returns, and follow the current buffer.
      filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        ignore_dirs = { "node_modules", ".git", "target", "dist", "build" },
      },
      reload_on_bufenter = true,
      update_focused_file = { enable = true, update_root = false },
      git = { enable = true, ignore = false, timeout = 500 },
    },
  },

  -- yazi.nvim — floating yazi file manager with image/PDF preview via
  -- kitty graphics protocol (works natively in Ghostty). Use this when you
  -- want to preview images/PDFs/videos from inside nvim. Requires `yazi`
  -- CLI on PATH — `sudo dnf install yazi` on Nobara/Fedora.
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>y",  "<cmd>Yazi<cr>",        desc = "Yazi at current file" },
      { "<leader>Y",  "<cmd>Yazi cwd<cr>",    desc = "Yazi at cwd" },
      { "<leader>yr", "<cmd>Yazi toggle<cr>", desc = "Resume last Yazi session" },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
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

  -- Treesitter (master branch is archived; main branch + Neovim 0.12 built-in TS)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "toml", "markdown",
        "markdown_inline", "html", "css", "javascript", "typescript", "tsx",
        "python", "go", "rust", "regex",
      },
    },
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
