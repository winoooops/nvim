-- init.lua — entry point
-- Load order matters: platform before options (clipboard),
-- keymaps before plugins (so leader is set), autocmds can load anywhere.

require("core.platform")
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- lazy.nvim bootstrap + plugin specs
require("plugins")

-- Optional machine-local overrides (gitignored, YAGNI — not created by default)
pcall(require, "local")
