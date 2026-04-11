# User Guide

A walkthrough of how this config is meant to be used day-to-day. Shorter than a manual, longer than a cheatsheet. Read it once, refer back to the recipes.

## Table of contents

- [Philosophy](#philosophy) — why this config looks the way it does
- [Daily startup](#daily-startup) — the first 10 seconds
- [The agent cockpit workflow](#the-agent-cockpit-workflow) — the whole reason this config exists
- [Finding and navigating](#finding-and-navigating) — files, projects, jumps
- [Editing with LSP](#editing-with-lsp) — completion, rename, references
- [Git review workflow](#git-review-workflow) — gitsigns → diffview → lazygit
- [AI integration](#ai-integration) — terminals, CodeCompanion, auth gotchas
- [File management](#file-management) — tree vs oil, when to use which
- [Recipes](#recipes) — "I want to X, here's how"
- [When things break](#when-things-break) — first aid

---

## Philosophy

This config is built around a specific claim: **in 2026, Neovim's primary job is not typing code, it's reviewing agent output.**

Most of your keystrokes aren't for writing code — they're for:

1. Reading what an agent (`claude`, `codex`, `gemini`) changed
2. Staging, rejecting, or tweaking those changes
3. Asking follow-up questions
4. Moving between buffers and files the agent is working on

So the config optimizes for **reading, diffing, and orchestrating**, not for raw typing speed.

The trio you'll use constantly:

- **toggleterm** splits for CLI agents (`<leader>tc`, `<leader>tx`, `<leader>tg`) — long-running agent loops live here
- **diffview** for reviewing multi-file changes (`<leader>dv`) — the moment after an agent reports "done"
- **lazygit** for staging/rejecting hunks (`<leader>g`) — the last step before committing agent work

The rest of the config is supporting infrastructure.

---

## Daily startup

```bash
cd <project>
nvim
```

You should see:

- Tokyonight theme, lualine at bottom, bufferline at top
- Snacks dashboard in the middle with recent files / shortcuts
- Nothing open yet

### First moves

Pick one:

- **`<leader>f`** — Telescope find files. Type a few characters to jump to a file.
- **`<leader>e`** — Open the file tree on the left.
- **`-`** — Open oil.nvim on the parent directory (edit the filesystem like text).

Then get a buffer open and the session has begun.

---

## The agent cockpit workflow

This is the canonical use pattern. Internalize this and the config clicks into place.

### The loop

```
1. Open the project in nvim.
2. <leader>tc  →  Claude CLI opens in a vertical split on the right.
3. Give Claude a task in natural language.
   (e.g., "refactor the auth middleware to use the new token library")
4. Claude edits files. Your buffers auto-reload and a yellow toast notifies
   you: "File changed on disk, reloaded: auth.go"
5. <leader>dv  →  Diffview opens showing every change across files.
   Walk through each diff. ]h / [h to jump between hunks.
6. For nits or partial changes: <leader>g to open lazygit. Stage hunks you
   want (space on a hunk line), discard ones you don't.
7. If you want a second opinion on a tricky diff: <leader>tx to open Codex
   in another split and ask it to review.
8. Commit in lazygit (c), push (P).
```

That's it. That's the whole workflow. Optionally:

- `<leader>ac` to ask Claude an in-editor question via CodeCompanion chat
- `<leader>tt` scratch shell for one-off commands
- `<leader>tg` Gemini for fast "what does this code do" questions

### Why this works

The hard part of agent-driven development isn't telling the agent what to do — it's **verifying what it did**. Every keybind above is optimized for verification, not generation.

---

## Finding and navigating

### Files

| Key | Tool | When |
|---|---|---|
| `<leader>f` | Telescope find_files | Fuzzy search by filename |
| `<leader>fs` | Smart-open | Recently edited first, then frecency |
| `<leader>fp` | Telescope projects | Jump between projects in project.nvim |
| `<S-j>` / `<S-k>` | buffer cycle | Jump between open buffers |
| `<leader>e` | nvim-tree | Visual directory tree |
| `-` | oil.nvim | Parent directory as editable buffer |

### Inside buffers

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References (telescope-like picker) |
| `gi` | Implementation |
| `K` | Hover docs |
| `[d` / `]d` | Prev / next diagnostic |

### Inside telescope

- `<C-j>` / `<C-k>` — move selection
- `<CR>` — open in current window
- `<C-v>` — open in vertical split
- `<C-x>` — open in horizontal split
- `<C-t>` — open in new tab
- `<Esc><Esc>` — cancel

---

## Editing with LSP

LSP servers are installed automatically by mason on first buffer open. Common stack installed out of the box: `lua_ls`, `pyright`, `ts_ls`, `gopls`, `rust_analyzer`, plus web stack (json, yaml, html, css, bash).

### First time a new language is opened

1. Open any file of that language.
2. Wait ~5 seconds. Mason downloads the server in the background.
3. A toast notification announces success.
4. LSP attaches automatically.

If a server fails to install, `:Mason` opens the manager UI — press `i` on the failing server to retry, inspect the log at the bottom of the UI if it keeps failing.

### Completion (blink.cmp)

- Starts typing → menu appears
- `<Tab>` next, `<S-Tab>` prev, `<CR>` accept, `<C-e>` close
- Documentation auto-shows after 200ms
- Sources: LSP → path → snippets → buffer

### Snippets

Friendly-snippets is loaded via LuaSnip. Type the trigger, press `<Tab>` to expand. Examples for Lua: `func` → function skeleton, `if` → if-block.

---

## Git review workflow

The git stack has three layers, use them in this order:

### 1. gitsigns — inline awareness
Signs appear in the gutter for added/modified/deleted lines. Use while editing:

- `]h` / `[h` — next / prev hunk
- `<leader>hp` — preview the hunk diff in a float
- `<leader>hs` — stage just this hunk
- `<leader>hu` — undo the staging
- `<leader>hr` — reset this hunk (throw away the change)
- `<leader>hb` — blame the current line
- `<leader>hd` — diff this buffer against HEAD

Use gitsigns for surgical, per-hunk decisions in the current file.

### 2. diffview — multi-file review
The best tool for "what did the agent change in this whole repo?":

- `<leader>dv` — open diffview, see all modified files in a list with diffs
- Navigate files in the left pane with `j`/`k`, press `<CR>` to focus
- `<leader>dh` — file history for the current buffer (useful for "what did the last agent run change?")
- `<leader>dc` — close diffview

### 3. lazygit — final staging + commit
Full-screen TUI for the final commit flow:

- `<leader>g` — open in floating window
- `space` — stage/unstage hunks or files
- `c` — commit
- `P` — push
- `q` — quit back to nvim

Combine them: **gitsigns while editing → diffview to review → lazygit to commit.**

---

## AI integration

### Terminal-split CLI agents

Each AI CLI gets its own persistent vertical-split terminal:

| Key | CLI | Notes |
|---|---|---|
| `<leader>tc` | `claude` | Primary agent (if installed on PATH) |
| `<leader>tx` | `codex` | Secondary / second opinion |
| `<leader>tg` | `gemini` | Fast questions |
| `<leader>tt` | `bash` (or your `$SHELL`) | Scratch |
| `<leader>g` | `lazygit` | Full-screen float |

Each terminal is persistent — toggle off with the same key, toggle back on, state is preserved. Terminals live for the whole nvim session.

**Inside a terminal buffer:**
- `<Esc>` — exit insert mode (switches to nvim normal mode on that buffer)
- `<C-hjkl>` — navigate out of the terminal into other splits
- `i` — enter insert mode again (type in the terminal)

### CodeCompanion in-editor chat

Sidebar chat buffer for quick questions without leaving nvim.

**Setup — this is the part most people miss:**

CodeCompanion hits `api.anthropic.com` directly, which needs a **real API key**, not the OAuth token from `claude setup-token`. You need:

1. Go to https://console.anthropic.com/settings/keys
2. Create a key (format: `sk-ant-api03-...`)
3. Add to your shell rc: `export ANTHROPIC_API_KEY="sk-ant-api03-..."`
4. `source ~/.bashrc` (or restart the shell)
5. **Restart nvim** — env vars are read at launch

The console API key is billed separately from Claude Max. If you want in-editor chat that uses Max quota instead, see [the Claude Code adapter](#using-claude-code-as-a-codecompanion-adapter) recipe below.

**Using the chat:**

```
<leader>ac    toggle the chat sidebar
```

Inside the chat buffer:
- Type your question on the last line
- `<C-s>` to send, streaming response appears below
- `<C-c>` to cancel a stream
- `/` at the start of a line opens slash commands (`/buffer`, `/file`, `/now`, `/url`)
- `#buffer` or `#file:path` to attach context
- `ga` (normal mode) to switch adapter mid-conversation

**Actions palette** — `<leader>aa` opens a picker with prebuilt prompts: Explain, Fix, Add tests, Refactor. Useful when you don't remember the exact slash command.

**Inline edit** — visual-select some code, `<leader>ae`, type an instruction. The selection gets rewritten. Accept with `ga`, reject with `gr`, or `u` to undo.

---

## File management

### nvim-tree (`<leader>e`)
Traditional sidebar tree. Good for:
- Quick orientation in a new project
- Drag-free navigation by keyboard
- Seeing file status (git diff markers)

Keys inside the tree: `a` add, `d` delete, `r` rename, `x` cut, `c` copy, `p` paste, `R` refresh.

### oil.nvim (`-`)
The directory is a buffer. Good for:
- Bulk renames (edit multiple lines, `:w`)
- Creating many files quickly
- Deleting a bunch of files at once (delete lines, `:w`)
- Feels like editing text — because it is

Press `-` to open the parent directory of the current buffer. Edit freely, `:w` to commit changes to the filesystem, `:q` or `<C-^>` to close.

**When to use which:** oil for bulk operations, nvim-tree for single-file orientation.

---

## Recipes

### Recipe: "Agent X edited my files, what did it change?"
```
<leader>dv          → diffview opens with everything
j/k                 → browse file list
<CR>                → focus a file
]c / [c             → next / prev change within the file
<leader>dc          → close when done
```

### Recipe: "I want to review commits by a specific author in this file"
```
<leader>dh          → file history diffview
<CR>                → open a commit
```

### Recipe: "I want to ask Claude about a specific function"
```
(visual-select the function body)
<leader>ae          → inline edit prompt
"explain what this does and flag anything suspicious"
```
Or for a longer chat:
```
<leader>ac          → chat sidebar
"What does #buffer do? Focus on the error handling around line 40."
<C-s>
```

### Recipe: "Bulk rename 10 files"
```
-                   → oil opens
(edit the lines in-place, change filenames)
:w                  → oil applies renames
```

### Recipe: "Agent broke something, roll back its changes"
```
<leader>g           → lazygit
(navigate to the agent's most recent commits)
D                   → diff
(in the commit view) r   → revert commit
```
Or file-by-file:
```
:e broken_file.lua
<leader>hr          → reset hunk (gitsigns)
```

### Recipe: "I'm on a new machine, set this up"
```bash
git clone git@github.com:winoooops/nvim.git ~/.config/nvim
cd ~/.config/nvim
cat docs/install.md  # per-OS deps
nvim                 # lazy bootstraps automatically
```

### Recipe: "I added a plugin, sync it to other machines"
```bash
# On the machine where you added the plugin:
cd ~/.config/nvim
# edit lua/plugins/<domain>.lua
nvim +"Lazy sync" +qa
git add lua/plugins/ lazy-lock.json
git commit -m "feat(plugins): add <plugin-name>"
git push

# On each other machine:
cd ~/.config/nvim
git pull
nvim +"Lazy restore" +qa
```

### Using Claude Code as a CodeCompanion adapter

**Goal:** use your Claude Max subscription for in-editor chat instead of paying for API credits.

CodeCompanion has (or had, check the current plugin docs) a `claude_code` adapter that routes requests through the local `claude` CLI instead of hitting the API directly. This uses your Max quota.

Rough setup — verify against current CodeCompanion docs before committing:

1. Ensure `claude` CLI is installed and authenticated (`claude setup-token` once per machine).
2. Edit `lua/plugins/ai.lua`, in the `strategies.chat.adapter` line change `"anthropic"` to `"claude_code"` (if that adapter exists in your installed CodeCompanion version).
3. Restart nvim.

If the adapter doesn't exist, check the [CodeCompanion repo](https://github.com/olimorris/codecompanion.nvim) README for the current list of supported adapters. Alternative: keep using `<leader>tc` terminal split which already uses Max quota for free.

---

## When things break

### Toolbox order of operations
1. `:checkhealth lazy vim.lsp vim.treesitter vim.provider telescope` — the reliable-signal subset
2. `:Lazy` — open the plugin manager UI. Anything in red or with ⚠️ is a plugin-level problem.
3. `:Mason` — LSP / formatter / linter installer. Failing installs show their logs here.
4. `:messages` — shows the last error messages. Good first stop for "something flashed on screen but it's gone now".
5. `:LspInfo` — shows which LSP servers are attached to the current buffer.
6. `:TSUpdate` — force treesitter parsers to re-sync if syntax highlighting looks off.

### Specific symptoms
- **Icons look like squares/tofu** → Nerd Font not set in terminal emulator. On WSL2, fix it in Windows Terminal settings. See [install.md § 3](install.md#3-jetbrainsmono-nerd-font).
- **Yank doesn't paste in Windows** (WSL2) → install `win32yank.exe`. See [install.md § 4](install.md#4-wsl2-clipboard-bridge-wsl2-only).
- **`<leader>g` does nothing** → lazygit binary not installed, or nvim launched before terminal.lua was fixed. Install lazygit, restart nvim.
- **`<leader>ac` opens chat but errors on send** → `ANTHROPIC_API_KEY` not set or wrong format. See [AI integration](#ai-integration) above.
- **LSP not attaching** → mason is probably still downloading. Wait 30 seconds and try again. If it keeps failing, `:Mason` to inspect logs.
- **"parser could not be created"** → treesitter parser not yet compiled. `:TSUpdate` and wait. Self-heals on subsequent launches.
- **"module not found"** on first launch of a new machine → `:Lazy restore` to pull the locked plugins.

Full list: [troubleshooting.md](troubleshooting.md).

---

## Related docs

- [Cheatsheet](cheatsheet.md) — one-page quick reference
- [Keybindings](keybindings.md) — exhaustive keymap table
- [Install](install.md) — per-OS setup
- [Updating](updating.md) — sync and upgrade flows
- [Troubleshooting](troubleshooting.md) — common issues with fixes
- [../CHANGELOG.md](../CHANGELOG.md) — what changed and when
