# lua/core

Core modules loaded by `init.lua` before any plugin. Each file has one responsibility.

| File | Responsibility |
|---|---|
| `platform.lua` | OS detection (macOS/Linux/WSL2) and WSL2 clipboard wiring via `win32yank.exe` |
| `options.lua` | All `vim.opt` settings — indentation, search, clipboard, splits, etc. |
| `keymaps.lua` | Global keybindings. Preserved 2022 set + new `<leader>a/t/d` namespaces |
| `autocmds.lua` | Agent-friendly auto-reload, yank highlight, trailing whitespace strip, split resize |

## Load order

```
platform → options → keymaps → autocmds → plugins
```

Platform must load first because it sets `vim.g.clipboard` for WSL2 before `options.lua` reads `clipboard`. Keymaps must load before plugins so `<leader>` is set before plugin `keys = {...}` specs are evaluated.

## Adding a new core module

1. Create the file in `lua/core/`
2. Add `require("core.<name>")` to `init.lua`
3. Update this README
