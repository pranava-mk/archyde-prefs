# Workspace Map

## Purpose
GNU Stow-managed dotfiles and config repo for pranava-mk's Arch Linux + HyDE setup — single source of truth for all tracked configs, deployable on any fresh install.

## Workspace Inventory

| Workspace | Folder | What lives here |
|-----------|--------|-----------------|
| Desktop environment | `hyprland/` | Hyprland WM, Waybar, Zsh user config |
| Terminal | `kitty/` | Kitty terminal emulator config |
| Audio | `wireplumber/` | WirePlumber ALSA hardware rules |
| Fonts | `fontconfig/` | Fontconfig script-fallback rules |
| AI assistant | `claude-global/` | Global Claude Code config (CLAUDE.md) |
| Incident logs | `archyde-issues-fixes/` | System issue documentation |
| Context files | `_docs/` | Per-workspace context (not stowed) |

## Naming conventions
- Dated assets:    `YYYY-MM-DD_<slug>.md`
- Context files:   `_docs/<workspace>.md`  (read before starting any task in that workspace)
- Stow packages:   top-level folders only — internal structure mirrors `~/` layout exactly

## Critical constraint
**Never move or rename files inside a stow package.** Stow deploys by mirroring the internal directory tree relative to the package root. Moving anything breaks the symlink map.

## Navigation rules
1. Read this file first.
2. Identify which workspace the task belongs to.
3. Read `_docs/<workspace>.md` before doing anything else.
4. To add a new tracked config: create the stow package dir tree, copy the file in, delete the original, run `stow --target ~ <package>`.
5. After any change: `cd ~/archyde-prefs && git add -A && git commit -m "..." && git push`.

## Fresh install restore
```bash
git clone git@github.com:pranava-mk/archyde-prefs.git ~/archyde-prefs
cd ~/archyde-prefs
stow --target ~ hyprland kitty wireplumber fontconfig claude-global archyde-issues-fixes
fc-cache -fv
```

## Workspaces
See `_docs/<workspace>.md` for per-workspace detail.
