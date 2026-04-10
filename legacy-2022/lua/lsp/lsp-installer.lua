local installer_status_ok, lsp_installer = pcall(require, 'nvim-lsp-installer')

if not installer_status_ok then
  return
end 

-- lsp-installer setup
lsp_installer.on_server_ready(function(server)
  
  local options = {
    on_attach = require("lsp.lsp-handlers").on_attach,
    capabilities = require("lsp.lsp-handlers").capabilities
  }
  
  -- extends the options based on language-servers
  if server.name == "jsonls" then
    local jsonls_options = require("lsp.settings.jsonls")
    options = vim.tbl_deep_extend("force", jsonls_options, options)
  end

  if server.name == "sumneko_lua" then
    local sumneko_options = require("lsp.settings.sumneko_lua")
    options = vim.tbl_deep_extend("force", sumneko_options, options)
  end

  if server.name == "vuels" then
    local vuels_options = require("lsp.settings.vuels")
    options = vim.tbl_deep_extend("force", vuels_options, options)
  end

  server:setup(options)
end)
