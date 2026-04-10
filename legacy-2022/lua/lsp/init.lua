local lsp_status_ok, _ = pcall(require, 'lspconfig')
if not lsp_status_ok then
  return
end

require("lsp.lsp-installer")
require("lsp.lsp-handlers").setup()


