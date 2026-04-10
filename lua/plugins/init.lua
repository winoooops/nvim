-- lua/plugins/init.lua
-- lazy.nvim bootstrap. This is the only place that knows about lazy.
-- Plugin specs are imported from sibling files in lua/plugins/.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    error("lazy.nvim install failed")
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Each sibling file below returns a lazy.nvim plugin spec (or list of specs).
    { import = "plugins.ui" },
    { import = "plugins.editor" },
    { import = "plugins.git" },
    { import = "plugins.terminal" },
    { import = "plugins.lsp" },
    { import = "plugins.completion" },
    { import = "plugins.format" },
    { import = "plugins.lint" },
    { import = "plugins.ai" },
  },
  install = { colorscheme = { "tokyonight", "default" } },
  checker = { enabled = false }, -- don't auto-check for updates; user runs :Lazy sync manually
  change_detection = { notify = false },
})
