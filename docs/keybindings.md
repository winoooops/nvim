# Keybindings

Leader key: `<space>`. All mappings use `<leader>` = space unless marked otherwise.

## Windows & splits
| Key | Action |
|---|---|
| `<leader>sw` | Vertical split |
| `<leader>sW` | Horizontal split |
| `<leader>cw` | Close current split |
| `<leader>cW` | Close all other splits |
| `<C-h/j/k/l>` | Navigate splits |
| `<leader>lS` / `<leader>nS` | Resize horizontal |
| `<leader>ls` / `<leader>ns` | Resize vertical |

## Buffers & tabs
| Key | Action |
|---|---|
| `<S-k>` | Next buffer |
| `<S-j>` | Previous buffer |
| `<leader>w` | Delete current buffer |
| `<leader>W` | Delete all buffers |
| `<leader><leader>k` | Next tab |
| `<leader><leader>j` | Prev tab |
| `<leader><leader>n` | New tab |
| `<leader><leader>w` | Close tab |

## File explorer
| Key | Action |
|---|---|
| `<leader>e` | Toggle nvim-tree |
| `<leader>E` | `:Explore` (netrw) |
| `-` | Open oil.nvim in parent directory |

## Telescope
| Key | Action |
|---|---|
| `<leader>f` | Find files |
| `<leader>fp` | Projects |
| `<leader>fs` | Smart-open (recency + frecency) |

## Save + format
| Key | Action |
|---|---|
| `<leader>s` | Format buffer (conform → LSP fallback) then save |

## LSP
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover docs |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `[d` / `]d` | Prev/next diagnostic |
| `<leader>dl` | Show diagnostic line |

## Git (gitsigns + lazygit + diffview)
| Key | Action |
|---|---|
| `]h` / `[h` | Next/prev hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Undo stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff this |
| `<leader>g` | Toggle lazygit (floating) |
| `<leader>dv` | Diffview open |
| `<leader>dc` | Diffview close |
| `<leader>dh` | Diffview file history |

## AI (CodeCompanion)
| Key | Action |
|---|---|
| `<leader>ac` | Toggle chat sidebar |
| `<leader>aa` | Actions palette |
| `<leader>an` | New chat |
| `<leader>ae` | Inline edit (visual mode) |

## Terminals (toggleterm, vertical default)
| Key | Action |
|---|---|
| `<leader>tc` | Toggle Claude CLI |
| `<leader>tx` | Toggle Codex CLI |
| `<leader>tg` | Toggle Gemini CLI |
| `<leader>tt` | Toggle scratch shell |
| `<leader>tv` | Vertical layout |
| `<leader>th` | Horizontal layout |
| `<leader>tf` | Floating layout |
| `<esc>` (in term) | Leave insert mode |
| `<C-hjkl>` (in term) | Navigate out of terminal |

## Visual mode
| Key | Action |
|---|---|
| `<` / `>` | Indent and stay in visual |
| `J` / `K` (x-mode) | Move selection down/up |

## Insert-mode navigation (preserved from 2022)
`<C-h/j/k/l>`, `<C-w>`, `<C-e>`, `<C-b>`, `<C-a>`, `<C-i>` — classic readline-like movement.
