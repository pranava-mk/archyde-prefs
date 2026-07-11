# archyde-prefs

GNU Stow dotfiles repo for pranava-mk — Arch Linux + HyDE setup.

**Remote**: `git@github.com:pranava-mk/archyde-prefs.git`

---

## Repo layout

```
archyde-prefs/
├── install.sh               # Bootstrap script — runs all steps below automatically
├── packages/                # Package manifests (NOT a stow package)
│   ├── README.md            # Manifest docs + regeneration commands
│   ├── pacman-explicit.txt  # All explicitly installed packages
│   ├── pacman-native.txt    # Official-repo packages only
│   ├── pacman-aur.txt       # AUR packages only
│   ├── systemd-system-enabled.txt
│   └── systemd-user-enabled.txt
├── _docs/                   # Per-workspace context files (not stowed)
│   └── <workspace>.md
└── <package>/               # Each top-level dir = one stow package
```

---

## Stow packages

| Package | Deploys to | Contents |
|---|---|---|
| `hyprland` | `~/.config/`, `~/.config/zsh/` | Hyprland WM, Waybar layout, Zsh user config (user.zsh) |
| `kitty` | `~/.config/` | Kitty terminal config |
| `wireplumber` | `~/.config/` | ALSA rules (Creative Pebble channel swap fix) |
| `fontconfig` | `~/.config/` | Noto Indic/script font fallback rules |
| `claude-global` | `~/.claude/` | Global Claude Code config |
| `archyde-issues-fixes` | `~/Documents/` | System incident logs |
| `shell` | `~/`, `~/.config/zsh/` | Home dotfiles (.zshenv, .bashrc, .profile, .npmrc, .gitconfig) and Zsh user files (.zshrc, .zshenv, conf.d/otw.zsh, functions/bat.zsh) |
| `apps` | `~/.config/` | Per-app user configs: dunst, micro, starship, atuin, yazi, fastfetch, btop, qt5ct, qt6ct, Kvantum, zed, clipse, vim |
| `bin` | `~/bin/` | User scripts: openclaw-sandbox, setup-openclaw-sandbox |

---

## Fresh install restore

### Automated (recommended)

```bash
git clone git@github.com:pranava-mk/archyde-prefs.git ~/archyde-prefs
cd ~/archyde-prefs
./install.sh
```

`install.sh` handles (in order): native packages, paru + AUR packages, a HyDE installation gate (manual step — HyDE must be installed before stowing), conflict-safe stow of all 9 packages, enabling systemd units, and rebuilding the font cache.

**Important**: When prompted, confirm that HyDE ([prasanthrangan/hyprdots](https://github.com/prasanthrangan/hyprdots)) is already installed before the script proceeds to stow. HyDE lays down base configs that the stow packages override — stowing before HyDE installs will cause conflicts.

### Minimal alternative (stow only)

If packages and HyDE are already set up, apply just the dotfile symlinks:

```bash
cd ~/archyde-prefs
stow --target ~ hyprland kitty wireplumber fontconfig claude-global archyde-issues-fixes shell apps bin
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
