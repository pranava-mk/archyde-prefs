# Flameshot — Kvantum crash on Wayland (Hyprland)

**Date**: 2026-02-20
**Status**: Workaround in place — using grimblast+satty instead

---

## Versions at time of issue

| Package | Version |
|---|---|
| flameshot | 13.3.0-2 |
| kvantum | 1.1.6-1 |
| hyprland | 0.53.3-2 |

---

## Symptoms

- `Super+Shift+S` triggered display distortion / weird compositor state
- Flameshot opened as a regular tiled window instead of a fullscreen overlay
- Journal showed segfault in `libkvantum.so` during Qt widget teardown

## Root Cause

Flameshot runs via **XWayland** on Hyprland. The Kvantum Qt theme engine (`libkvantum.so`) crashes with a null-pointer dereference (`Kvantum::Style::removeFromSet -> QWidgetD2Ev -> QDialog::done`) when flameshot's overlay is torn down on Wayland. This corrupts the compositor state causing the visual distortion.

## Workaround

Replaced flameshot with native Wayland pipeline: **grimblast + satty**

Keybindings in `~/.config/hypr/keybindings.conf`:
```conf
bindd = $mainMod Shift, S, $d screenshot region, exec, bash -c 'f=~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; /home/cruxx/.local/lib/hyde/grimblast --freeze copysave area "$f" && satty --filename "$f"'
bindd = $mainMod, Print, $d screenshot fullscreen, exec, bash -c 'f=~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png; /home/cruxx/.local/lib/hyde/grimblast copysave screen "$f" && satty --filename "$f"'
bindd = $mainMod Shift, Print, $d screenshot to clipboard, exec, /home/cruxx/.local/lib/hyde/grimblast copy screen
```

---

## Switching back to Flameshot

When `flameshot`, `kvantum`, or `hyprland` gets an update, try reinstalling flameshot and swapping the keybindings back.

### Steps to test after update

```bash
# 1. Check updated versions
pacman -Q flameshot kvantum hyprland

# 2. Reinstall flameshot if removed
sudo pacman -S flameshot

# 3. Test launch directly (bypass Kvantum just in case)
QT_STYLE_OVERRIDE=fusion XDG_CURRENT_DESKTOP=Hyprland flameshot gui

# 4. Check for crash in journal
journalctl --user -n 30 | grep -i "flameshot\|kvantum\|segfault"

# 5. If no crash, restore keybindings in ~/.config/hypr/keybindings.conf:
bindd = $mainMod Shift, S, $d flameshot screenshot (GUI), exec, QT_STYLE_OVERRIDE=fusion XDG_CURRENT_DESKTOP=Hyprland flameshot gui
bindd = $mainMod, Print, $d flameshot fullscreen, exec, QT_STYLE_OVERRIDE=fusion XDG_CURRENT_DESKTOP=Hyprland flameshot full
bindd = $mainMod Shift, Print, $d flameshot screen to clipboard, exec, QT_STYLE_OVERRIDE=fusion XDG_CURRENT_DESKTOP=Hyprland flameshot screen -c
```

### What to watch for in changelogs
- **flameshot**: Wayland/wlr-layer-shell native support (no more XWayland fallback)
- **kvantum**: Fix for crash in `removeFromSet` / Qt6 Wayland teardown
- **hyprland**: XWayland Qt app overlay compatibility improvements
