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
    -- Matches the user's bashrc alias: NO_FLICKER=1 claude --dangerously-skip-permissions
    -- Bash aliases aren't expanded in non-interactive shells, so we inline the
    -- expansion here. If you don't want --dangerously-skip-permissions on a
    -- given machine, edit this line or fall back to `cmd = "bash -ic claude"`.
    local claude = Terminal:new({ cmd = "NO_FLICKER=1 claude --dangerously-skip-permissions", hidden = true, direction = "vertical", count = 11 })
    local codex = Terminal:new({ cmd = "codex", hidden = true, direction = "vertical", count = 12 })
    local gemini = Terminal:new({ cmd = "gemini", hidden = true, direction = "vertical", count = 13 })
    local scratch = Terminal:new({ hidden = true, direction = "vertical", count = 14 })
    local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", count = 15 })

    -- Expose lazygit toggle globally so keymaps.lua can call it.
    _G._LAZYGIT_TOGGLE = function() lazygit:toggle() end

    local function kset(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
    end

    kset("<leader>tc", function() claude:toggle() end, "Toggle Claude CLI")
    kset("<leader>tx", function() codex:toggle() end, "Toggle Codex CLI")
    kset("<leader>tg", function() gemini:toggle() end, "Toggle Gemini CLI")
    kset("<leader>tt", function() scratch:toggle() end, "Toggle scratch shell")

    -- <leader>ai — WSL2 only: save the Windows clipboard image to /tmp, copy
    -- the path to the + register, and send it into the ACTIVE agent terminal.
    -- Detection order: focused terminal → most recently opened → Claude fallback.
    -- Workflow:
    --   1. Win+Shift+S on Windows to capture a screenshot (goes to clipboard)
    --   2. <leader>ai in nvim → active terminal receives the path
    --   3. Press Enter in the terminal to submit
    local platform = require("core.platform")
    if platform.is_wsl then
      -- Named terminals in priority order for the "find active" search.
      local named_terminals = {
        { term = claude, name = "Claude" },
        { term = codex,  name = "Codex" },
        { term = gemini, name = "Gemini" },
        { term = scratch, name = "Shell" },
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
        local script = vim.fn.stdpath("config") .. "/bin/wsl-clip-img"
        local result = vim.fn.system(script)
        if vim.v.shell_error ~= 0 then
          vim.notify("wsl-clip-img: " .. (result or "failed"), vim.log.levels.WARN, { title = "Clip image" })
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
      vim.api.nvim_create_user_command("WslClipImg", send_clip_img, {
        desc = "Save Windows clipboard image to /tmp and send path to active agent terminal",
      })
      kset("<leader>ai", send_clip_img, "Send Windows clipboard image → active terminal")
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
        -- Only override <Esc> → terminal-normal mode. Nothing else.
        vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], o)
      end,
    })
  end,
}
