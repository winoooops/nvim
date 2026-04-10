# lua/plugins

One file per plugin domain. Each file returns a lazy.nvim plugin spec (or list of specs) and is imported from `lua/plugins/init.lua`.

## Domain index

| File | Status | Plugins |
|---|---|---|
| `init.lua` | ✅ | lazy.nvim bootstrap + domain imports |
| `ui.lua` | ✅ | tokyonight, catppuccin, mini.icons, lualine, bufferline, which-key, snacks.nvim, markview |
| `editor.lua` | ✅ | telescope, smart-open, project.nvim, nvim-tree, oil.nvim, treesitter (pinned to `master` branch — see note), rainbow-delimiters, nvim-autopairs, Comment.nvim, indent-blankline |
| `git.lua` | ✅ | gitsigns, diffview.nvim |
| `terminal.lua` | ✅ | toggleterm (vertical default, named Claude/Codex/Gemini/lazygit terminals) |
| `lsp.lua` | ✅ | mason, mason-lspconfig, nvim-lspconfig (lua_ls, pyright, ts_ls, gopls, rust_analyzer, jsonls, yamlls, bashls, html, cssls) |
| `completion.lua` | ✅ | blink.cmp, LuaSnip, friendly-snippets |
| `format.lua` | ✅ | conform.nvim |
| `lint.lua` | ✅ | nvim-lint |
| `ai.lua` | ✅ CodeCompanion / ⏸ copilot.lua commented out | CodeCompanion.nvim (Anthropic/OpenAI/Ollama) |

## Status legend
- ✅ active
- ⏸ present but disabled (commented out)
- 🚧 in progress

## Note on nvim-treesitter

`nvim-treesitter` is pinned to `branch = "master"` because the plugin's default branch migrated to `main` with a rewritten API that removes the classic `require("nvim-treesitter.configs")` setup. The `master` branch is archived upstream but still functional. A future migration to the new `main`-branch API is a known follow-up.

## Adding a plugin

1. Open the file for the appropriate domain (or create a new file for a new domain).
2. Add the plugin spec.
3. Update this README's table.
4. Add an entry to `CHANGELOG.md` under `[Unreleased]`.
5. Run `:Lazy sync` and commit both the file and `lazy-lock.json`.

## Adding a plugin domain

1. Create `lua/plugins/<domain>.lua` returning a spec table.
2. Add `{ import = "plugins.<domain>" }` to `lua/plugins/init.lua`.
3. Add a row to this README.
