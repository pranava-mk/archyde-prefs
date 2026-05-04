# Hyprland workspace

## What this is for
Tracks all Hyprland WM configs, the Waybar status bar layout, and Zsh user environment setup. Changes here affect the live desktop immediately via symlinks. HyDE (the theme system) manages some files in `~/.config/hypr/` — only the files listed below are tracked here; the rest are HyDE-owned and must not be stowed.

## Folder contents

| Path inside package | Live symlink target | What it controls |
|---|---|---|
| `.config/hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` | Main compositor config, exec-once, source list |
| `.config/hypr/keybindings.conf` | `~/.config/hypr/keybindings.conf` | All keyboard shortcuts |
| `.config/hypr/userprefs.conf` | `~/.config/hypr/userprefs.conf` | Gaps, borders, touchpad, decoration |
| `.config/hypr/monitors.conf` | `~/.config/hypr/monitors.conf` | Dual-monitor layout (DP-1 + eDP-1) |
| `.config/hypr/windowrules.conf` | `~/.config/hypr/windowrules.conf` | Per-app window rules (Hyprland 0.53+ syntax) |
| `.config/hypr/workspaces.conf` | `~/.config/hypr/workspaces.conf` | Workspace bindings |
| `.config/hypr/hypridle.conf` | `~/.config/hypr/hypridle.conf` | Idle / lock screen trigger config |
| `.config/hypr/CLAUDE.md` | `~/.config/hypr/CLAUDE.md` | Hyprland-specific AI context |
| `.config/waybar/layouts/pranava-split-pill.jsonc` | `~/.config/waybar/layouts/pranava-split-pill.jsonc` | Canonical Waybar layout |
| `.config/waybar/WAYBAR.md` | `~/.config/waybar/WAYBAR.md` | Waybar layout documentation |
| `.config/zsh/user.zsh` | `~/.config/zsh/user.zsh` | PATH, env vars (sourced early, before fzf) |

## HyDE-managed files (do NOT stow)
`animations.conf`, `hyde.conf`, `nvidia.conf`, `shaders.conf`, `hyprlock.conf`, `workflows.conf` — overwritten by theme switcher.

## Routing table

| Task | Read | Skip |
|---|---|---|
| Add/change keybinding | `keybindings.conf` | everything else |
| Change gaps/borders/touchpad | `userprefs.conf` | — |
| Add window rule | `windowrules.conf` + `~/.config/hypr/CLAUDE.md` for syntax | — |
| Change monitor layout | `monitors.conf` | — |
| Change Waybar layout | `pranava-split-pill.jsonc` + `WAYBAR.md` | `config.jsonc` (generated, do not edit) |
| Change shell env / PATH | `.config/zsh/user.zsh` | `~/.zshrc` (not auto-sourced) |
| Theme change | HyDE docs | this repo |

## Conventions
- Waybar: edit `pranava-split-pill.jsonc`, then run `~/.local/lib/hyde/waybar.py --update` to regenerate `config.jsonc`.
- Windowrules: Hyprland 0.53+ syntax — `windowrule = <prop> <val>, match:<type> <pattern>`.
- After any config edit: `hyprctl reload` to apply live.
- Restart Waybar: `systemctl --user restart hyde-Hyprland-bar.service`.

## Available skills
| Skill | When to use |
|---|---|
| `organise-workspace` | Restructure this repo's documentation |
| `new-task` | Plan a multi-step config change |
