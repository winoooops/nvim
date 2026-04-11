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
    -- the path to the + register, and send it into the Claude terminal
    -- (opening it first if needed). Workflow:
    --   1. Win+Shift+S on Windows to capture a screenshot (goes to clipboard)
    --   2. <leader>ai in nvim → Claude terminal opens, path is typed at prompt
    --   3. Press Enter in Claude to submit
    local platform = require("core.platform")
    if platform.is_wsl then
      local function send_clip_img_to_claude()
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
        -- Open the Claude terminal (if not already open) and send the path
        if not claude:is_open() then claude:open() end
        claude:send(path, false)
        vim.notify("Sent to Claude: " .. path, vim.log.levels.INFO, { title = "Clip image" })
      end
      vim.api.nvim_create_user_command("WslClipImg", send_clip_img_to_claude, {
        desc = "Save Windows clipboard image to /tmp and send path to Claude CLI",
      })
      kset("<leader>ai", send_clip_img_to_claude, "Send Windows clipboard image → Claude")
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
