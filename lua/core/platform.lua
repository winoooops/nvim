-- lua/core/platform.lua
-- Detects the OS and exposes booleans used by other modules
-- (primarily for clipboard setup on WSL2).
local M = {}

local uname = vim.loop.os_uname()
local sysname = uname.sysname or ""

M.is_mac = sysname == "Darwin"
M.is_wsl = vim.env.WSL_DISTRO_NAME ~= nil
M.is_linux = sysname == "Linux" and not M.is_wsl
M.is_windows = sysname:match("Windows") ~= nil

-- Wire WSL2 clipboard to win32yank.exe so yanks flow to Windows clipboard.
-- Requires `win32yank.exe` on PATH (installed via docs/install.md).
if M.is_wsl then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

return M
