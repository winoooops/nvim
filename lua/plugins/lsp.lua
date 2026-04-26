-- lua/plugins/lsp.lua
-- mason + mason-lspconfig + nvim-lspconfig.
-- Replaces the 2022 nvim-lsp-installer setup.

-- Register LSP keymaps via LspAttach autocmd. This works regardless of
-- whether the server was configured via the legacy `lspconfig.setup()`
-- API or the newer `vim.lsp.config()` / `vim.lsp.enable()` model that
-- nvim-lspconfig now uses internally on Neovim 0.11+.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local function m(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end
    m("gd", vim.lsp.buf.definition, "Go to definition")
    m("gD", vim.lsp.buf.declaration, "Go to declaration")
    m("gr", vim.lsp.buf.references, "References")
    m("gi", vim.lsp.buf.implementation, "Implementation")
    -- Hover moved off `K` so <S-k> stays free for :bnext (buffer
    -- cycling). `gh` fits the existing g* LSP nav pattern.
    m("gh", vim.lsp.buf.hover, "Hover docs")
    m("<leader>rn", vim.lsp.buf.rename, "Rename")
    m("<leader>ca", vim.lsp.buf.code_action, "Code action")
    m("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    m("]d", vim.diagnostic.goto_next, "Next diagnostic")
    m("<leader>dl", vim.diagnostic.open_float, "Diagnostic line")
  end,
})

local function on_attach(_, bufnr)
  -- Kept for parity with the legacy API path; the LspAttach autocmd above
  -- is the source of truth and fires on both APIs.
end

return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",  -- must load before LSPs so its capabilities are available
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",        -- was sumneko_lua in 2022
          "pyright",
          "ts_ls",         -- was tsserver
          "gopls",
          "rust_analyzer",
          "jsonls",
          "yamlls",
          "bashls",
          "html",
          "cssls",
        },
      })

      local lspconfig = require("lspconfig")
      -- blink.cmp's capabilities advertise snippet support, additionalTextEdits,
      -- resolve-on-select, etc. Without this servers (rust-analyzer especially)
      -- send sparse completions: function names but no signatures, types, or
      -- snippet bodies.
      local ok_blink, blink = pcall(require, "blink.cmp")
      local capabilities = ok_blink
        and blink.get_lsp_capabilities()
        or vim.lsp.protocol.make_client_capabilities()

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim", "Snacks" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        },
        pyright = {},
        ts_ls = {},
        gopls = {},
        rust_analyzer = {},
        jsonls = {},
        yamlls = {},
        bashls = {},
        html = {},
        cssls = {},
      }

      for name, cfg in pairs(servers) do
        cfg.on_attach = on_attach
        cfg.capabilities = capabilities
        lspconfig[name].setup(cfg)
      end

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}
