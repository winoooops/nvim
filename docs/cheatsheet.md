# Cheatsheet

One-page quick reference. Print it, screenshot it, bookmark it. Leader = `<space>`.

---

## 🎯 Core motion (preserved from 2022 — muscle memory)

```
WINDOWS              BUFFERS              TABS                 VISUAL
<leader>sw  vsplit   <S-k>   next buf    <leader><leader>k    <  / >   indent
<leader>sW  hsplit   <S-j>   prev buf    <leader><leader>j    J  / K   move lines
<leader>cw  close    <leader>w delete    <leader><leader>n    (in visual mode)
<leader>cW  only     <leader>W del all   <leader><leader>w
<C-h/j/k/l> navigate
<leader>ls  wider    SAVE + FORMAT
<leader>ns  narrower <leader>s  format & write (conform → LSP fallback)
```

## 🔍 Find things (telescope)

```
<leader>f    find files (project root)
<leader>fp   projects (project.nvim)
<leader>fs   smart open (recent + frecency)
<leader>?    which-key buffer local help
```

Inside telescope: `<C-j/k>` move, `<CR>` open, `<C-v>` vsplit, `<C-x>` hsplit, `<Esc><Esc>` cancel.

## 📁 File tree & oil

```
<leader>e    toggle nvim-tree
<leader>E    netrw :Explore
-            open oil.nvim (parent dir as buffer)
```

**nvim-tree:** `a` add, `d` delete, `r` rename, `x` cut, `c` copy, `p` paste, `<CR>` open.
**oil:** edit the buffer like text — save (`:w`) to apply. Rename with `cw`, delete a line to delete the file.

## 🛠 LSP (on_attach)

```
gd    definition       <leader>rn  rename        [d / ]d  prev / next diagnostic
gD    declaration      <leader>ca  code action   <leader>dl  diagnostic float
gr    references       K           hover docs
gi    implementation
```

**Completion (blink.cmp):** `<Tab>` / `<S-Tab>` cycle, `<CR>` accept, `<C-e>` close, docs show after ~200ms.

## 🤖 AI cockpit (the 2026 layer)

### CLI terminals (persistent, vertical split 40% width)
```
<leader>tc    Claude CLI      <leader>tt  scratch shell
<leader>tx    Codex CLI       <leader>g   lazygit (float)
<leader>tg    Gemini CLI

<leader>tv  force vertical   <leader>th  force horizontal   <leader>tf  force float
```
Inside terminal: `<Esc>` to normal mode, `<C-hjkl>` navigate out.

### In-editor chat (CodeCompanion — needs `ANTHROPIC_API_KEY`)
```
<leader>ac   toggle chat sidebar        <leader>an   new chat
<leader>aa   actions palette            <leader>ae   inline edit (visual)
```
Inside chat: `<C-s>` send, `<C-c>` cancel, `ga` switch adapter, `q` close.

## 🔀 Git — agent diff review

```
<leader>g    lazygit (the main git UI)

Hunks (gitsigns on the current buffer):
  ]h  next    [h  prev    <leader>hp  preview    <leader>hs  stage
  <leader>hu  undo stage  <leader>hr  reset      <leader>hb  blame    <leader>hd  diff

Diffview (multi-file review — perfect after agents edit):
  <leader>dv  open     <leader>dc  close    <leader>dh  file history (this file)
```

## 🔄 Plugin management (lazy.nvim)

```
:Lazy          open manager UI
:Lazy sync     update plugins + regenerate lockfile  (run on primary machine)
:Lazy restore  align plugins to committed lockfile   (run on other machines after git pull)
:Mason         LSP/formatter/linter installer
:checkhealth   full health report  (use per-plugin for cleaner output)
```

## ⚡ Daily cross-machine sync

```bash
# Primary machine — after making config changes:
cd ~/.config/nvim && nvim +"Lazy sync" +qa && git add lazy-lock.json
git commit -m "chore: bump plugins" && git push

# Any other machine:
cd ~/.config/nvim && git pull && nvim +"Lazy restore" +qa
```

## 🧭 Cognitive map — what lives where

```
core         ┌─ platform.lua    WSL2 clipboard + OS detection
             ├─ options.lua     vim.opt settings
             ├─ keymaps.lua     all global keybindings
             └─ autocmds.lua    agent auto-reload + yank highlight

plugins      ┌─ ui.lua          theme, lualine, bufferline, snacks, which-key, markview
             ├─ editor.lua      telescope, tree, oil, treesitter, comment, indent
             ├─ git.lua         gitsigns, diffview
             ├─ terminal.lua    toggleterm + named AI CLI terminals
             ├─ lsp.lua         mason, lspconfig, 10 servers
             ├─ completion.lua  blink.cmp + LuaSnip
             ├─ format.lua      conform.nvim
             ├─ lint.lua        nvim-lint
             └─ ai.lua          CodeCompanion (copilot stubbed)

docs         ┌─ cheatsheet.md       ← you are here
             ├─ user-guide.md       fuller walkthrough with workflow recipes
             ├─ keybindings.md      exhaustive keymap table
             ├─ install.md          per-OS setup
             ├─ troubleshooting.md  common issues
             └─ updating.md         sync + upgrade flows
```

---

**Forgot something?** → [docs/user-guide.md](user-guide.md) has the full walkthrough.
**Looking for a key?** → [docs/keybindings.md](keybindings.md) has every mapping in one table.
**Something broken?** → [docs/troubleshooting.md](troubleshooting.md).
