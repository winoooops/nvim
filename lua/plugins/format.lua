-- lua/plugins/format.lua
-- conform.nvim replaces null-ls for formatting.
-- <leader>s in keymaps.lua calls conform.format() directly.

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format", "ruff_fix" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      go = { "gofmt" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
    },
    default_format_opts = { lsp_format = "fallback" },
  },
}
