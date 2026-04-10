local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

configs.setup {
  -- see https://github.com/nvim-treesitter/nvim-treesitter for more
  ensure_installed = "all",
  sync_install = false,
  auto_install = true,
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = { "yaml" } },

  -- see https://github.com/p00f/nvim-ts-rainbow for more 
  rainbow = {
    enable = true, 
    extended_mode = true,
    max_file_lines = nil
  },
}
