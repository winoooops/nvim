# Updating

## Update Neovim itself
Infrequent — maybe twice a year. Follow the install instructions again:
- macOS: `brew upgrade neovim`
- Debian/Ubuntu (PPA): `sudo apt update && sudo apt upgrade neovim`
- Arch: `sudo pacman -Syu neovim`

After upgrading, launch nvim once and run `:checkhealth` to confirm nothing broke.

## Update plugins

### On your primary machine
```bash
cd ~/.config/nvim
nvim +"Lazy sync" +qa
git add lazy-lock.json
git diff --cached lazy-lock.json | head -20  # sanity check
git commit -m "chore: bump plugins $(date +%Y-%m-%d)"
git push
```

Add an entry to `CHANGELOG.md` if any plugin was added, removed, or had a meaningful behavior change.

### On every other machine
```bash
cd ~/.config/nvim
git pull
nvim +"Lazy restore" +qa
```

`:Lazy restore` aligns the local plugin install to the exact commits in the lockfile. Much safer than `:Lazy sync`, which would pull latest upstream and create drift.

## Add or remove a plugin
1. Edit the appropriate `lua/plugins/<domain>.lua` file.
2. Update `lua/plugins/README.md` domain index.
3. Add an entry to `CHANGELOG.md` under `[Unreleased]`.
4. `:Lazy sync` to install/uninstall.
5. Commit the plugin file, the README, the CHANGELOG, and `lazy-lock.json` in one commit.
6. Push.

## Roll back a bad sync
```bash
cd ~/.config/nvim
git log --oneline lazy-lock.json | head -5
git checkout <prev-commit> -- lazy-lock.json
nvim +"Lazy restore" +qa
```

## Check what's different from origin
```bash
git fetch
git log --oneline HEAD..origin/main
```
