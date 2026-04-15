# tmux config

Synced alongside the nvim config. Catppuccin-inspired status bar, vi-mode copy, and sensible defaults for the agent cockpit workflow.

## Quick setup

```bash
# Symlink into place (the repo lives at ~/.config/nvim)
ln -sf ~/.config/nvim/tmux/tmux.conf ~/.tmux.conf

# Install TPM (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reload tmux config
tmux source-file ~/.tmux.conf

# Install plugins (inside tmux)
# Press: Ctrl+b I   (capital I)
# Or from shell:
~/.tmux/plugins/tpm/bin/install_plugins
```

## Plugins

| Plugin | Purpose |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key) | `Ctrl+b Space` shows all available bindings |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions across restarts (`Ctrl+b Ctrl+s` save, `Ctrl+b Ctrl+r` restore) |

## Keybindings cheatsheet

Prefix: `Ctrl+b`

### Sessions & windows
```
Ctrl+b c        new window (keeps current path)
Ctrl+b &        kill window
Ctrl+b ,        rename window
Ctrl+b d        detach session
Ctrl+b s        switch session
Ctrl+b $        rename session
Alt+1..5        jump to window 1-5 (no prefix needed)
Alt+h / Alt+l   prev / next window (no prefix needed)
```

### Panes
```
Ctrl+b |        vertical split (keeps current path)
Ctrl+b -        horizontal split (keeps current path)
Ctrl+b x        kill pane
Ctrl+b z        zoom/unzoom pane (toggle fullscreen)
Alt+arrows      navigate panes (no prefix needed)
Ctrl+arrows     resize panes (no prefix needed)
```

### Copy mode (vi keys)
```
Ctrl+b [        enter copy mode
v               start selection
y               yank (copies to Windows clipboard via clip.exe)
q               exit copy mode
Ctrl+b ]        paste from tmux buffer
```

Tip: hold `Shift` while mouse-selecting to bypass tmux and use your terminal's native clipboard. Then `Ctrl+Shift+C` to copy.

### Utility
```
Ctrl+b r        reload tmux.conf
Ctrl+b ?        popup cheatsheet (requires ~/.tmux/cheatsheet.md)
Ctrl+b Space    which-key popup — shows all available bindings
Ctrl+b I        install plugins via TPM
Ctrl+b U        update plugins via TPM
```

### tmux-resurrect (session persistence)
```
Ctrl+b Ctrl+s   save current session layout
Ctrl+b Ctrl+r   restore last saved session
```

Sessions survive tmux server restarts (but not reboots unless you save first).

## Clipboard note (WSL2)

The copy-mode `y` key pipes to `clip.exe` — this writes to the Windows clipboard directly from WSL2. On macOS, change `clip.exe` to `pbcopy` in `tmux.conf`. On native Linux, use `xclip -selection clipboard` or `wl-copy`.

## Updating

```bash
cd ~/.config/nvim
git pull
ln -sf ~/.config/nvim/tmux/tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf
```
