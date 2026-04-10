local status_ok, bufferline = pcall(require, 'bufferline')

if not status_ok then
  return
end

bufferline.setup({
  options = {
    numbers = nil,
    close_command = "Bdelete! %d", -- use molly/bbye instead of native bufferdelete 
    right_mouse_command = nil,
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,
    indicator_icon = "▎",
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 18,
    max_prefix_length = 15,
    tab_size = 10,
    diagnostics = "nvim_lsp",
    offsets = {{ filetype = 'NvimTree', text = "", padding = 1}}, -- so that buffertabs and nvimtree won't collide 
    custom_filter = function(bufnr)
      -- if the result is false, this buffer will be shown, otherwise, this
      -- buffer will be hidden.

      -- filter out filetypes you don't want to see
      local exclude_ft = { "qf", "fugitive", "git" }
      local cur_ft = vim.bo[bufnr].filetype
      local file_should_stay = not vim.tbl_contains(exclude_ft, cur_ft)

      --- only see the buffer in the active tab
      local only_show_active_buffers = vim.api.nvim_buf_get_name(bufnr):find(vim.fn.getcwd(), 0, true)

      if only_show_active_buffers then
        return true
      end
    end,
    custom_areas = {
      right = function()
        local result = {}
        local seve = vim.diagnostic.severity
        local error = #vim.diagnostic.get(0, {severity = seve.ERROR})
        local warning = #vim.diagnostic.get(0, {severity = seve.WARN})
        local info = #vim.diagnostic.get(0, {severity = seve.INFO})
        local hint = #vim.diagnostic.get(0, {severity = seve.HINT})

        if error ~= 0 then
          table.insert(result, {text = "  " .. error, guifg = "#EC5241"})
        end

        if warning ~= 0 then
          table.insert(result, {text = "  " .. warning, guifg = "#EFB839"})
        end

        if hint ~= 0 then
          table.insert(result, {text = "  " .. hint, guifg = "#A3BA5E"})
        end

        if info ~= 0 then
          table.insert(result, {text = "  " .. info, guifg = "#7EA9A7"})
        end
        return result
      end
    },
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    separator_style = "thick",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    sort_by = "id",
  }
})
