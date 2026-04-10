local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    print("Couldnot find packer")
    return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

return packer.startup(
    function()
        -- Packer can manage itself
        use 'wbthomason/packer.nvim'

        -- two plugins that are being used for many nvim repos
        use "nvim-lua/popup.nvim"
        use "nvim-lua/plenary.nvim"

        -- gruvbox theme
        use {
            "ellisonleao/gruvbox.nvim",
            requires = {"rktjmp/lush.nvim"}
        }
        -- which-key
        use {
            "folke/which-key.nvim", 
            event = "VimEnter", 
            config = [[require('config.which-key')]]
        }

        -- Auto format tools
        use({ "sbdchd/neoformat", cmd = { "Neoformat" } })
        -- Auto Pairs 
        use({ "windwp/nvim-autopairs", config=[[require('config.autopairs')]]})
        -- colorful parentesis
        use "p00f/nvim-ts-rainbow"
        -- fix issues when I use :bdelete 
        use "moll/vim-bbye"

        -- A list of colorscheme plugin you may want to try. Find what suits you.
        use "folke/tokyonight.nvim"
        -- use "lifepillar/vim-gruvbox8"
        -- use "navarasu/onedark.nvim"
        -- use "sainnhe/edge"
        -- use "sainnhe/sonokai"
        -- use "sainnhe/gruvbox-material"
        use "shaunsingh/nord.nvim"
        use "NTBBloodbath/doom-one.nvim"
        use "sainnhe/everforest"
        use "EdenEast/nightfox.nvim"

        -- use({ "akinsho/bufferline.nvim", event = "VimEnter", config = [[require('config.bufferline')]] })

        -- Highlight URLs inside vim
        use({"itchyny/vim-highlighturl", event = "VimEnter"})
        -- show git change
        use({"mhinz/vim-signify", event = 'BufEnter'})
        -- colorful status line and theme
        use({ "vim-airline/vim-airline-themes", after = 'vim-signify',})
        use({ "vim-airline/vim-airline", after = 'vim-airline-themes', config = [[ require('config.airline')]]})
        use({ "akinsho/bufferline.nvim", event = "VimEnter", config = [[require('config.bufferline')]] })
        -- Alpha-nvim
        use { 'goolord/alpha-nvim', event = 'VimEnter', config = [[require('config.alpha')]] }
        -- markdown preview
        -- use "iamcco/markdown-preview.vim"
        use { "iamcco/markdown-preview.nvim", run="cd app && yarn install", cmd="MarkdownPreview"}
        use { "ellisonleao/glow.nvim" } 

        -- notification plugin
        use({ "rcarriga/nvim-notify", event = "BufEnter", config = [[require('config.nvim-notify')]]})

        -- auto completion
        use({ "hrsh7th/nvim-cmp", config = [[require('config.cmp')]] })                        -- auto completion
        use "hrsh7th/cmp-buffer"                      -- buffer completion 
        use "hrsh7th/cmp-path"                        -- path completion 
        use "hrsh7th/cmp-cmdline"                     -- command-line completion
        use "saadparwaiz1/cmp_luasnip"                -- snippet completion
        use "hrsh7th/cmp-nvim-lsp"                    -- provide LSP completions via cmp
        use "hrsh7th/cmp-nvim-lua"

        -- snippets
        use "L3MON4D3/LuaSnip"                        -- snippet engine
        use "rafamadriz/friendly-snippets"            -- useful snippets across different languages


        -- LSP
        use "neovim/nvim-lspconfig"                 -- enable LSP
        use "williamboman/nvim-lsp-installer"         -- use servers to manage language support
        use({ "jose-elias-alvarez/null-ls.nvim", config = [[require('config.null-ls')]]})

        -- fuzzy-finding via telescope 
        use({"nvim-telescope/telescope.nvim", config=[[require('config.telescope')]]})
        -- enable media preview in telescope 
        use "nvim-telescope/telescope-media-files.nvim"
        -- smart fuzzy find 
    --
        -- should run sudo apt-get install sqlite3 libsqlite3-dev
        use {
          "nvim-telescope/telescope-frecency.nvim",
          requires = {"tami5/sqlite.lua"}
        }

        -- treesitting
        use({
          "nvim-treesitter/nvim-treesitter",
          run=":TSUpdate",
          config=[[require('config.treesitter')]]
        })

        -- better comments 
        use({"numToStr/Comment.nvim", config=[[require('config.comments')]]})
        use 'JoosepAlviste/nvim-ts-context-commentstring'

        -- git signs 
        use({"lewis6991/gitsigns.nvim", config=[[require('config.gitsigns')]]})

        -- nvim-tree
        use 'nvim-tree/nvim-web-devicons'
        use({'nvim-tree/nvim-tree.lua', config=[[require('config.nvimtreeconfig')]]})

        -- terminal tools 
        use({ "akinsho/toggleterm.nvim", config=[[require('config.toggleterm')]]})

        -- indentline 
        use({ "lukas-reineke/indent-blankline.nvim", main = "ibl", config = [[require('config.indentline')]]})

        -- project managers
        use({ "ahmedkhalf/project.nvim", config = [[require('config.projects')]]})

        -- github copilot 
        use "github/copilot.vim"
    end
)

-- local status, _ = pcall(require, 'packer_compiled')
-- if not status then
--  vim.notify("Error requiring packer_compiled.lua: run PackerSync to fix!")
-- end
