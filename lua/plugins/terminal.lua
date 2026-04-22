-- lua/plugins/terminal.lua
-- toggleterm.nvim configured for the DHH cockpit:
-- default layout = vertical split, named persistent terminals for
-- claude/codex/gemini/lazygit + a scratch shell.

return {
  "akinsho/toggleterm.nvim",
  -- Eager load. The config function creates _G._LAZYGIT_TOGGLE and the
  -- <leader>t* keymaps, both referenced by keymaps.lua. Lazy-loading via
  -- `keys` string stubs caused those bindings to be shadowed; lazy-loading
  -- via VeryLazy didn't fire in headless/cmd invocations. A small plugin,
  -- cost is negligible.
  lazy = false,
  cmd = { "ToggleTerm", "TermExec" },
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "vertical",
      size = function(term)
        if term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        elseif term.direction == "horizontal" then
          return math.floor(vim.o.lines * 0.3)
        end
        return 20
      end,
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      persist_mode = true,
      close_on_exit = true,
      float_opts = { border = "rounded" },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    -- Named persistent terminals. Each has a unique count so toggling
    -- reopens the same instance.
    -- Claude is launched with NO_FLICKER=1 + --effort max + skip-perms.
    -- Bash aliases aren't expanded in non-interactive shells, so the flags
    -- are inlined here. Drop/swap flags per-machine as needed; for a more
    -- conservative default use `cmd = "bash -ic claude"` and rely on the
    -- shell alias.
    local claude = Terminal:new({ cmd = "NO_FLICKER=1 claude --effort max --dangerously-skip-permissions", hidden = true, direction = "vertical", count = 11 })
    local codex = Terminal:new({ cmd = "codex", hidden = true, direction = "vertical", count = 12 })
    local gemini = Terminal:new({ cmd = "gemini", hidden = true, direction = "vertical", count = 13 })
    local kimi = Terminal:new({ cmd = "kimi", hidden = true, direction = "vertical", count = 16 })
    -- Scratch shell: lives BELOW the editor window only (not spanning
    -- the full screen width). toggleterm can't do a "split within a
    -- specific column", so we drop to native Neovim :split | :terminal.
    -- Focus the editor window first so the split doesn't land below the
    -- tree or an agent panel.
    local scratch_buf = nil

    local function focus_editor_window()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bt = vim.bo[buf].buftype
        local ft = vim.bo[buf].filetype
        if bt ~= "terminal" and ft ~= "NvimTree" and ft ~= "oil" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end

    local function toggle_scratch()
      -- Visible somewhere? Hide it.
      if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
        local wins = vim.fn.win_findbuf(scratch_buf)
        if #wins > 0 then
          for _, w in ipairs(wins) do
            pcall(vim.api.nvim_win_close, w, false)
          end
          return
        end
      end
      -- Hidden or doesn't exist. Open below the editor.
      focus_editor_window()
      vim.cmd("belowright split")
      -- 13% of total screen height (13 is a Fibonacci number — gives a
      -- compact, quick-glance scratch strip rather than a heavy pane).
      vim.cmd("resize " .. math.floor(vim.o.lines * 0.13))
      if scratch_buf and vim.api.nvim_buf_is_valid(scratch_buf) then
        vim.api.nvim_win_set_buf(0, scratch_buf)
      else
        vim.cmd("terminal")
        scratch_buf = vim.api.nvim_get_current_buf()
      end
      vim.cmd("startinsert")
    end
    -- Lazygit is a full TUI — Esc is used for "cancel / go back" at every
    -- level, so our global <Esc> → terminal-normal mapping is actively
    -- harmful here. on_open forces insert mode and removes the remap so
    -- Esc passes straight through to lazygit.
    local lazygit = Terminal:new({
      cmd = "lazygit",
      hidden = true,
      direction = "float",
      count = 15,
      on_open = function(term)
        vim.cmd("startinsert!")
        pcall(vim.keymap.del, "t", "<esc>", { buffer = term.bufnr })
      end,
    })

    -- Expose lazygit toggle globally so keymaps.lua can call it.
    _G._LAZYGIT_TOGGLE = function() lazygit:toggle() end

    local function kset(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
    end

    kset("<leader>tc", function() claude:toggle() end, "Toggle Claude CLI")
    kset("<leader>tx", function() codex:toggle() end, "Toggle Codex CLI")
    kset("<leader>tg", function() gemini:toggle() end, "Toggle Gemini CLI")
    kset("<leader>tk", function() kimi:toggle() end, "Toggle Kimi CLI")
    kset("<leader>tt", toggle_scratch, "Toggle scratch shell (below editor)")

    -- <leader>ai — WSL2 or native Linux: save the clipboard image to /tmp,
    -- copy the path to the + register, and send it into the ACTIVE agent terminal.
    -- Detection order: focused terminal → most recently opened → Claude fallback.
    -- Workflow:
    --   1. Take a screenshot into the clipboard:
    --        • WSL2:  Win+Shift+S
    --        • Linux: Spectacle / Print Screen / Flameshot (enable "copy to clipboard")
    --   2. <leader>ai in nvim → active terminal receives the path
    --   3. Press Enter in the terminal to submit
    local platform = require("core.platform")
    if platform.is_wsl or platform.is_linux then
      local clip_script = platform.is_wsl and "/bin/wsl-clip-img" or "/bin/linux-clip-img"
      -- Named terminals in priority order for the "find active" search.
      local named_terminals = {
        { term = claude, name = "Claude" },
        { term = codex,  name = "Codex" },
        { term = gemini, name = "Gemini" },
        { term = kimi,   name = "Kimi" },
      }

      -- Find the best terminal to send to: focused > open > Claude fallback.
      local function find_active_terminal()
        -- First pass: is any named terminal focused (its window is the current one)?
        for _, t in ipairs(named_terminals) do
          if t.term:is_focused() then return t end
        end
        -- Second pass: is any named terminal visible (open in a split)?
        for _, t in ipairs(named_terminals) do
          if t.term:is_open() then return t end
        end
        -- Fallback: Claude (will be opened by the caller if not already).
        return named_terminals[1]
      end

      local function send_clip_img()
        local script = vim.fn.stdpath("config") .. clip_script
        local result = vim.fn.system(script)
        if vim.v.shell_error ~= 0 then
          vim.notify("clip-img: " .. (result or "failed"), vim.log.levels.WARN, { title = "Clip image" })
          return
        end
        local path = vim.trim(result)
        if path == "" then
          vim.notify("No path returned", vim.log.levels.WARN, { title = "Clip image" })
          return
        end
        -- Put on clipboards for fallback paste
        vim.fn.setreg("+", path)
        vim.fn.setreg('"', path)
        -- Find the active terminal and send the path there
        local target = find_active_terminal()
        if not target.term:is_open() then target.term:open() end
        target.term:send(path, false)
        vim.notify("Sent to " .. target.name .. ": " .. path, vim.log.levels.INFO, { title = "Clip image" })
      end
      vim.api.nvim_create_user_command("ClipImg", send_clip_img, {
        desc = "Save clipboard image to /tmp and send path to active agent terminal",
      })
      -- Keep the old command alias for existing muscle memory.
      vim.api.nvim_create_user_command("WslClipImg", send_clip_img, { desc = "Alias of :ClipImg" })
      kset("<leader>ai", send_clip_img, "Send clipboard image → active terminal")
    end

    -- Layout overrides — act on the last-active toggleterm
    kset("<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", "Toggle vertical term")
    kset("<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", "Toggle horizontal term")
    kset("<leader>tf", "<cmd>ToggleTerm direction=float<CR>", "Toggle float term")

    -- Terminal-mode overrides. Keep this minimal — claude/codex CLIs use
    -- control keys (<C-j> for newline, <C-n>/<C-p> for history, etc.) and
    -- any override here shadows them. To navigate out of a terminal split,
    -- press <Esc> first (enters terminal normal mode) then use <C-hjkl>
    -- which is a normal-mode mapping from keymaps.lua.
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*",
      callback = function()
        local o = { buffer = 0, silent = true }
        -- <Esc>   → exit to terminal-normal mode (for Neovim navigation)
        -- <C-]>   → send raw ESC to the TUI app (e.g. exit detail view in
        --           Claude, escape from ctrl-z mode, back out of menus)
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], o)
        vim.keymap.set("t", "<C-]>", "\x1b", o)
      end,
    })
  end,
}
