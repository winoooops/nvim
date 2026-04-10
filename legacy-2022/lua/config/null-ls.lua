local status_ok, null_ls = pcall(require, 'null-ls')

if not status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion

null_ls.setup({
  sources = {
    formatting.stylua,
    formatting.eslint,
    formatting.stylelint,
    formatting.prettier,
    diagnostics.eslint,
    diagnostics.jsonlint,
    diagnostics.stylelint,
    completion.spell,
  }
})
