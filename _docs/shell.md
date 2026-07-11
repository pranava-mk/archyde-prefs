# shell workspace

## What this is for
Tracks home-directory dotfiles and Zsh user configuration files — the files that live in `~/` or `~/.config/zsh/` and define the interactive shell environment, environment variables, and per-tool shell integrations.

## Folder contents

| File (repo path) | Live path | Purpose |
|---|---|---|
| `shell/.zshenv` | `~/.zshenv` | Sets ZDOTDIR → redirects Zsh config to `~/.config/zsh/` |
| `shell/.bashrc` | `~/.bashrc` | Bash interactive shell config |
| `shell/.profile` | `~/.profile` | POSIX login shell env (used by bash login shells) |
| `shell/.npmrc` | `~/.npmrc` | npm global prefix → `~/.npm-global/` |
| `shell/.gitconfig` | `~/.gitconfig` | Git user identity and core settings |
| `shell/.config/zsh/.zshenv` | `~/.config/zsh/.zshenv` | Zsh env vars (sourced early, non-interactive) |
| `shell/.config/zsh/.zshrc` | `~/.config/zsh/.zshrc` | Zsh interactive config (atuin init lives here) |
| `shell/.config/zsh/conf.d/otw.zsh` | `~/.config/zsh/conf.d/otw.zsh` | Extra aliases/functions loaded by HyDE's conf.d loader |
| `shell/.config/zsh/functions/bat.zsh` | `~/.config/zsh/functions/bat.zsh` | bat-based manpager function |

## Deliberately untracked files

| File | Reason |
|---|---|
| `~/.zshrc` | DEAD FILE — `~/.zshenv` sets `ZDOTDIR=~/.config/zsh`, so Zsh never reads `~/.zshrc`. HyDE may write it; it is ignored at runtime. Do not track it. |
| `~/.gtkrc-2.0` | nwg-look regenerates this file on every GTK theme change. Tracking it would cause constant noise and conflicts. |

## Routing table

| Task | Read | Skip |
|---|---|---|
| Change PATH or env vars | `shell/.config/zsh/.zshenv` (early, non-interactive) | `.zshrc` |
| Add keybinding-sensitive init (e.g. atuin) | `shell/.config/zsh/.zshrc` (sourced after fzf) | `.zshenv` |
| Add a shell alias or function | `shell/.config/zsh/conf.d/otw.zsh` | — |
| Change Git identity | `shell/.gitconfig` | — |

## Conventions

- **user.zsh lives in the hyprland package** at `hyprland/.config/zsh/user.zsh` — do not duplicate it here. user.zsh is the primary PATH/env file that HyDE's terminal.zsh sources early. The `shell` package adds extra files that complement it.
- Load order (HyDE terminal sessions): `~/.zshenv` → `user.zsh` → OMZ + fzf → `~/.config/zsh/.zshrc`. Place anything that must run after fzf (e.g. `eval "$(atuin init zsh)"`) in `.zshrc`, not `.zshenv` or `user.zsh`.
- See `_docs/hyprland.md` for the full Zsh load-order detail.
