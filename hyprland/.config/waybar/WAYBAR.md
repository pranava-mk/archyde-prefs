# Waybar Configuration

Personal Waybar setup for pranava-mk on Arch/HyDE.

**Layout file** (canonical source): `layouts/pranava-split-pill.jsonc`
→ symlinked via stow from `~/archyde-prefs/hyprland/.config/waybar/`
→ `config.jsonc` is regenerated from this file by `~/.local/lib/hyde/waybar.py --update`

---

## Pill Layout

```
LEFT                          CENTER                RIGHT
[workspaces] [window title]   [cava · idle · clock]  [cpu · mem] [updates] [wifi · vpn] [vol · mic] [battery] [tray] [menu]
```

### Left
| Pill | Modules | Notes |
|---|---|---|
| `pill#left` | `hyprland/workspaces` | Workspace switcher |
| `pill#window` | `hyprland/window` | Active window title with app rewrites (Firefox, VSCode, Dolphin, etc.) — max 50 chars |

### Center
| Pill | Modules | Notes |
|---|---|---|
| `pill#center` | `custom/cava`, `idle_inhibitor`, `clock` | Cava visualizer, idle inhibitor toggle, clock |

### Right (left → right order)
| Pill | Modules | Notes |
|---|---|---|
| `pill#sysinfo` | `cpu`, `memory` | CPU % (10s interval), RAM used GB (30s interval) |
| `pill#updates` | `custom/updates` | Pending pacman+AUR update count. Polls once per day. Click to open updater. Tooltip shows package list |
| `pill#network` | `network`, `custom/vpn` | WiFi icon; VPN shows `󰖂 <connection-name>` when active, empty when off. Polls nmcli every 5s |
| `pill#audio` | `pulseaudio`, `pulseaudio#microphone` | Speaker + mic volume |
| `pill#battery` | `battery` | Always shows `icon + %`. See override below |
| `pill#tray` | `tray` | System tray icons |
| `pill#menu` | `custom/hyde-menu`, `custom/power` | HyDE menu + power menu |

---

## Module Overrides

These are defined directly in `pranava-split-pill.jsonc` and take precedence over HyDE's included module definitions.

### battery
```jsonc
"battery": {
    "format": "{icon} {capacity}%",
    "format-alt": "{icon} {capacity}%",   // mirrors format — click-toggle has no visible effect
    "format-charging": " {capacity}%",
    "format-plugged": " {capacity}%",
    "format-icons": ["󰂎","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]
}
```
`format-alt` must match `format` — Waybar's battery module has a built-in C-level click toggle
between `format` and `format-alt` that `on-click: ""` does NOT suppress.

### custom/vpn
```jsonc
"custom/vpn": {
    "exec": "nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2~/vpn|wireguard/{print \"󰖂 \" $1}'",
    "interval": 5,
    "format": "{}"
}
```
Works with NetworkManager VPN connections and WireGuard. Empty output when no VPN active.

---

## Removed / Intentionally Absent Modules

| Module | Reason |
|---|---|
| `backlight` | Not needed — brightness keys work without indicator |
| `custom/keybindhint` | Use `Super+/` instead |
| `custom/cliphist` | Use `Super+V` / `Super+Shift+V` instead |
| `custom/hyprsunset` | Broken / non-functional on this system |
| `bluetooth` | Removed from network pill — icon showed connected device count with no way to suppress it without the override being ignored |
| `custom/mediaplayer` | Clutters center pill; YouTube Music / Spotify controllable via media keys |
| `power-profiles-daemon` | Using `auto-cpufreq` instead |

---

## Persistence

HyDE state (`~/.local/state/hyde/staterc`) stores:
```
WAYBAR_LAYOUT_PATH=/home/cruxx/.config/waybar/layouts/pranava-split-pill.jsonc
WAYBAR_LAYOUT_NAME=pranava-split-pill
```
This survives reboots and theme changes — HyDE will always reload `pranava-split-pill.jsonc`.

---

## Editing

Edit the layout file directly (symlink keeps git in sync automatically):
```bash
micro ~/.config/waybar/layouts/pranava-split-pill.jsonc

# Apply changes
~/.local/lib/hyde/waybar.py --update
systemctl --user restart hyde-Hyprland-bar.service

# Commit
cd ~/archyde-prefs && git add -A && git commit -m "waybar: <description>"
```

## Restore on New Machine

```bash
cd ~/archyde-prefs && stow --target ~ hyprland
~/.local/lib/hyde/waybar.py --set pranava-split-pill
systemctl --user restart hyde-Hyprland-bar.service
```

---

*Last updated: 2026-02-25*
