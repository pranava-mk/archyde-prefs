# Workspace Map

## Purpose
GNU Stow-managed dotfiles and config repo for pranava-mk's Arch Linux + HyDE setup — single source of truth for all tracked configs, deployable on any fresh install.

## Workspace Inventory

| Workspace | Folder | What lives here |
|-----------|--------|-----------------|
| Desktop environment | `hyprland/` | Hyprland WM, Waybar, Zsh user config (user.zsh) |
| Terminal | `kitty/` | Kitty terminal emulator config |
| Audio | `wireplumber/` | WirePlumber ALSA hardware rules |
| Fonts | `fontconfig/` | Fontconfig script-fallback rules |
| AI assistant | `claude-global/` | Global Claude Code config (CLAUDE.md) |
| Incident logs | `archyde-issues-fixes/` | System issue documentation |
| Shell | `shell/` | Home dotfiles + Zsh user files (.zshenv, .bashrc, .profile, .npmrc, .gitconfig, .config/zsh/{.zshrc,.zshenv,conf.d,functions}) |
| App configs | `apps/` | Per-app user configs: dunst, micro, starship, atuin, yazi, fastfetch, btop, qt5ct, qt6ct, Kvantum, zed, clipse, vim |
| User scripts | `bin/` | ~/bin scripts: openclaw-sandbox, setup-openclaw-sandbox |
| Package manifests | `packages/` | pacman + systemd manifests — NOT a stow package |
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
./install.sh
```

`install.sh` installs packages, gates on HyDE being present (manual step), stows all 9 packages, enables systemd units, and runs `fc-cache -fv`.

**Manual alternative** (stow only, after packages + HyDE are ready):

```bash
cd ~/archyde-prefs
stow --target ~ hyprland kitty wireplumber fontconfig claude-global archyde-issues-fixes shell apps bin
fc-cache -fv
```

## Workspaces
See `_docs/<workspace>.md` for per-workspace detail.
