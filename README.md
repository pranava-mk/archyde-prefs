# archyde-prefs

GNU Stow dotfiles repo for pranava-mk — Arch Linux + HyDE setup.

**Remote**: `git@github.com:pranava-mk/archyde-prefs.git`

---

## Stow packages

| Package | Deploys to | Contents |
|---|---|---|
| `hyprland` | `~/.config/` | Hyprland configs, Waybar layout, Zsh user config |
| `kitty` | `~/.config/` | Kitty terminal config |
| `wireplumber` | `~/.config/` | ALSA rules (Creative Pebble channel swap fix) |
| `fontconfig` | `~/.config/` | Noto Indic/script font fallback rules |
| `claude-global` | `~/.claude/` | Global Claude Code config |
| `archyde-issues-fixes` | `~/Documents/` | System incident logs |

---

## Fresh install restore

```bash
git clone git@github.com:pranava-mk/archyde-prefs.git ~/archyde-prefs
cd ~/archyde-prefs
stow --target ~ hyprland kitty wireplumber fontconfig claude-global archyde-issues-fixes
fc-cache -fv
```

---

## Daily workflow

Edit files at their live locations — symlinks write through to this repo.

```bash
cd ~/archyde-prefs
git add -A
git commit -m "description"
git push
```

---

## Adding a new config to tracking

```bash
# 1. Mirror the path inside the package
mkdir -p ~/archyde-prefs/<package>/<path-relative-to-home>/

# 2. Copy the file in
cp ~/path/to/file ~/archyde-prefs/<package>/<path-relative-to-home>/

# 3. Remove the original
rm ~/path/to/file

# 4. Stow creates the symlink
cd ~/archyde-prefs && stow --target ~ <package>

# 5. Commit
git add -A && git commit -m "feat: track <file>" && git push
```

---

See `CLAUDE.md` for full workspace map and navigation rules.
