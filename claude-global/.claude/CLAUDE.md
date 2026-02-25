# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Claude Behavior Instructions

- **Always benchmark before and after performance-related changes.** Run the relevant benchmark command before touching anything, record the result, make the change, then benchmark again to show the actual improvement.

---

# Arch Linux System Configuration
## Personal Setup Documentation for pranava-mk

This document captures the complete configuration of this Arch Linux installation for reproducibility and future automation.

---

## System Information

- **Distribution**: Arch Linux (rolling release)
- **Kernel**: Linux LTS 6.12.57-1-lts (primary), Linux 6.16.5.arch1-1 (secondary)
- **CPU**: Intel (with intel-ucode microcode updates)
- **Bootloader**: systemd-boot (bootctl) with efibootmgr
- **Init System**: systemd
- **Display Manager**: SDDM
- **Desktop Environment**: HyDE (Hyprland Desktop Environment)
- **Window Manager**: Hyprland 0.53.3

---

## Package Management

### Package Managers
- **pacman**: Official Arch repositories
- **paru**: AUR helper (default configuration)
- **snapd**: Snap package manager (enabled)

### Package Statistics
- **Explicitly Installed**: 126 packages
- **AUR Packages**: 116 packages

### Essential Packages

#### System Base
```
base, base-devel, linux-lts, linux-lts-headers, linux-firmware
intel-ucode, efibootmgr, btrfs-progs, zram-generator
```

#### Display & Graphics
```
hyprland, sddm, xdg-desktop-portal-hyprland, xdg-desktop-portal-gtk
vulkan-intel, vulkan-tools
qt5-wayland, qt6-wayland, qt5ct, qt6ct
```

#### Audio
```
pipewire, pipewire-audio, pipewire-alsa, pipewire-jack, pipewire-pulse
wireplumber, pamixer, pavucontrol
```

#### Networking
```
networkmanager, network-manager-applet, bluez, bluez-utils, blueman
```

#### System Utilities
```
btop, fastfetch, reflector, auto-cpufreq
brightnessctl, udiskie, polkit-gnome
parallel, tree, ncdu, wget, unzip, bc
```

---

## Desktop Environment: HyDE

### Overview
HyDE (Hyprland Desktop Environment) - a heavily customized Hyprland setup with theming system.

**Project**: [prasanthrangan/hyprdots](https://github.com/prasanthrangan/hyprdots)

### HyDE Components
- **Compositor**: Hyprland with custom configs
- **Status Bar**: Waybar (managed by systemd: `hyde-Hyprland-bar.service`)
- **Launcher**: Rofi
- **Notifications**: Dunst
- **Wallpaper**: swww (animated wallpaper daemon)
- **Lock Screen**: hyprlock
- **Idle Management**: hypridle
- **Color Temperature**: hyprsunset
- **Color Picker**: hyprpicker

### Hyprland Configuration

**Location**: `~/.config/hypr/`

**File Structure**:
```
hyprland.conf       # Main config, sources all others
userprefs.conf      # Personal preferences (persists across theme changes)
monitors.conf       # Multi-monitor setup
keybindings.conf    # Keyboard shortcuts
windowrules.conf    # Window-specific rules
themes/theme.conf   # HyDE theme settings (managed by theme switcher)
```

### Monitor Configuration

**Setup**: Dual monitor (laptop + external)

```conf
# External monitor (DP-1): 2560x1440@60Hz, positioned top, primary
monitor = DP-1, 2560x1440@60, 0x0, 1

# Laptop display (eDP-1): 1920x1080@60Hz @ 1.2 scale, centered below
monitor = eDP-1, 1920x1080@60, 480x1440, 1.2
```

### Key Hyprland Customizations

#### Window Appearance (userprefs.conf)
```conf
general {
    gaps_in = 0        # No gaps between windows
    gaps_out = 0       # No gaps around workspaces
    border_size = 0    # No window borders
}

decoration {
    dim_inactive = false    # Native dimming disabled
    dim_strength = 0.0
}

input {
    touchpad {
        natural_scroll = yes    # Natural touchpad scrolling enabled
    }
}
```

#### Window Dimming: hyprdim
Native Hyprland dimming is disabled. Using **hyprdim v3.0.1** for temporary dimming on focus switch.

**Autostart** (in hyprland.conf):
```bash
exec-once = hyprdim --strength 0.7 --duration 800
```

**Behavior**:
- Dims briefly when switching windows, then fades back
- Solo windows don't dim (hyprdim v3.x default behavior)
- `--strength 0.7`: Strong dimming intensity (0.0-1.0 range)
- `--duration 800`: Removes dim after 800ms

**Restart dimming**:
```bash
pkill hyprdim && hyprdim --strength 0.7 --duration 800 &
```

### Available Themes

Located in: `~/.themes/` and `~/.local/share/themes/`

**Installed Themes**:
- Vanta-Black (current preference)
- Catppuccin-Mocha
- Catppuccin-Latte
- Rose-Pine
- Tokyo-Night
- Gruvbox-Retro
- Graphite-Mono
- Material-Sakura
- Synth-Wave
- Decay-Green
- Nordic-Blue
- Edge-Runner
- Frosted-Glass

**Theme Management**: HyDE provides `hydectl` for theme switching

### Wallpaper Management

**Multi-monitor wallpaper fix**:
If DP-1 shows black wallpaper after connecting:
```bash
~/.local/lib/hyde/wallpaper.sh --start --backend swww --global
```

### Waybar (Status Bar)

**Important**: Waybar is managed by systemd user service
- Service: `hyde-Hyprland-bar.service`
- Don't start waybar manually (causes duplicate bars)
- Restart: `systemctl --user restart hyde-Hyprland-bar.service`

**Layout**: Personal split-pill layout (`~/.config/waybar/config.jsonc`)
- Left pill: `hyprland/workspaces`
- Center pill: `custom/cava`, `idle_inhibitor`, `clock`
- Right pill (general): `backlight`, `pulseaudio`, `pulseaudio#microphone`, `battery`, `custom/hyprsunset`
- Right pill (tray): `tray`
- Right pill (menu): `custom/hyde-menu`, `custom/power`

**Removed modules** (covered by keybindings):
- `custom/keybindhint` — use `Super+/` instead
- `custom/cliphist` — use `Super+V` / `Super+Shift+V` instead

---

## Terminal Environment

### Terminal Emulator: Kitty

**Version**: 0.44.0-1
**Config**: `~/.config/kitty/kitty.conf`
**Font**: CaskaydiaCove Nerd Font Mono
**Font Size**: 12.0

**Configuration**:
```conf
include hyde.conf    # Includes HyDE theme integration

# Font settings (in hyde.conf)
font_family CaskaydiaCove Nerd Font Mono
font_size 12.0
window_padding_width 25

# Tab bar styling
tab_bar_edge = bottom
tab_bar_style = powerline
tab_powerline_style = slanted
```

**Startup Display**: anifetch (animated ASCII art on terminal startup)
```bash
anifetch ~/.local/share/anifetch/venv/lib/python3.13/site-packages/anifetch/assets/example.mp4
```

### Shell: Zsh

**Version**: 5.9-5
**Framework**: Oh My Zsh
**Theme**: robbyrussell
**Plugins**: git

**Config Files**:
- `~/.zshrc` - Main zsh configuration
- `~/.zshenv` - Environment variables (sources `$XDG_CONFIG_HOME/zsh/.zshenv`)

### Shell Tools & Enhancements

#### Atuin (Command History)
Enhanced shell history with sync capabilities
```zsh
eval "$(atuin init zsh)"
```

#### Zoxide (Smarter cd)
Fast directory jumper that learns your habits
```zsh
eval "$(zoxide init zsh)"
```

#### Starship Prompt
Fast, customizable prompt (installed but not actively configured in .zshrc)

#### FZF
Fuzzy finder for command-line

### Shell Environment Variables

```zsh
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH
export EDITOR='micro'
export VISUAL='micro'
export ZSH="$HOME/.oh-my-zsh"
```

### Shell Integrations
- **Kiro**: AI coding assistant shell integration
```zsh
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
```

---

## Editors & IDEs

### Primary Editor: Micro

**Default editor for**:
- Shell (`$EDITOR` and `$VISUAL`)
- Git commits (`core.editor`)

**Config**: `~/.config/micro/`

### Available IDEs
- **Visual Studio Code** (`visual-studio-code-bin`)
- **Cursor** (`cursor-bin`) - AI code editor
- **Kiro** (`kiro-bin`) - AI coding assistant
- **Vim** - Available as backup editor

---

## Web Browsers

**Installed**:
- **Brave** (`brave-bin`) - Primary browser (Chromium-based)
- **Firefox** - Secondary browser
- **Microsoft Edge** (`microsoft-edge-stable-bin`) - Available

---

## Development Tools

### Version Control
**Git Configuration** (`~/.gitconfig`):
```ini
[user]
    name = Pranava
    email = 98644231+pranava-mk@users.noreply.github.com
[init]
    defaultBranch = main
[pull]
    rebase = false
[core]
    editor = micro
```

**Git Commit Preferences** (from global CLAUDE.md):
- Remove "Co-Authored-By: Claude" messages from commits
- Push as `pranava-mk`, not as Claude

### Programming Languages & Runtimes
- **Node.js**: npm 11.6.2-1 (global packages in `~/.npm-global/`)
- **Python**: python-pipx for tool installation
- **Java**: jre-openjdk 21.u35-3
- **Go**: Installed with config in `~/.config/go/`

### Container & Virtualization
- **Docker**: 1:28.5.2-1

### CLI Development Tools
- **jq**: JSON processor
- **bat**: Better `cat` with syntax highlighting
- **tldr**: Simplified man pages
- **yazi**: Terminal file manager

---

## System Services

### Enabled System Services
```
bluetooth.service                  # Bluetooth daemon
NetworkManager.service            # Network management
sddm.service                      # Display manager
auto-cpufreq.service             # CPU frequency optimization
snapd.service                    # Snap daemon
systemd-timesyncd.service        # Time synchronization
```

### Enabled User Services
```
wireplumber.service              # Pipewire session manager
xdg-user-dirs.service           # User directories
pipewire.socket                 # Pipewire audio
pipewire-pulse.socket           # Pulseaudio compatibility
```

### Auto-cpufreq
Automatic CPU frequency and power management for laptops
- Service: `auto-cpufreq.service`
- Config location: `~/auto-cpufreq/` (git repository clone)

---

## Utilities & Applications

### System Monitoring
- **btop**: Resource monitor (alternative to htop)
- **fastfetch**: System information display

### Screenshots & Screen Capture
- **grimblast**: Screenshot tool (HyDE bundled, native Wayland) — replaces Flameshot
- **satty**: Screenshot annotation (opens after capture for markup)
- **grim**: Wayland screenshot utility (used by grimblast)
- **slurp**: Select screen region (used by grimblast)
- ~~**Flameshot**~~: Removed — crashes due to Kvantum/XWayland segfault on Hyprland (see `~/Documents/archyde-issues-fixes/2026-02-20_flameshot-kvantum-crash.md`)

### Clipboard Management
- **cliphist**: Clipboard history for Wayland
- **wl-clip-persist**: Persistent clipboard

### File Management
- **Dolphin**: KDE file manager
- **yazi**: Terminal file manager
- **Ark**: Archive manager

### Media
- **playerctl**: Media player controller
- **spotify-launcher**: Spotify client
- **ani-cli**: Watch anime from CLI

### Communication
- **Signal Desktop**: Secure messaging
- **Telegram Desktop**: Messaging
- **Microsoft Edge**: For web apps

### Productivity
- **OnlyOffice**: Office suite
- **Notion (Enhanced)**: Note-taking

### Gaming
- **Heroic Games Launcher**: Epic Games & GOG client
- **Steam**: Via snap
- **Hedgewars**: Turn-based strategy game
- **SuperTuxKart**: Racing game

---

## Custom Scripts & Binaries

### Location
- `~/bin/`
- `~/.local/bin/`

### Custom Tools
```
anifetch              # Animated ASCII art terminal greeting
claude-code-agents    # Claude Code agent utilities
hydectl               # HyDE control utility
hyde-shell            # HyDE shell integration
openclaw-sandbox      # OpenClaw game sandbox
setup-openclaw-sandbox  # OpenClaw setup script
zed                   # Zed editor
```

---

## UI Preferences & Theming

### Qt Configuration
- **Qt5**: qt5ct for Qt5 theming
- **Qt6**: qt6ct for Qt6 theming
- **Kvantum**: Theme engine for Qt applications (Qt5 & Qt6)

### GTK Configuration
- **GTK-3.0**: `~/.config/gtk-3.0/`
- **GTK-4.0**: Symlinked to Vanta-Black theme
  ```
  ~/.config/gtk-4.0 -> ~/.local/share/themes/Vanta-Black/gtk-4.0
  ```

### Current Theme
- **Primary**: Vanta-Black
- **Icon Theme**: (Set via nwg-look)

### Theme Tools
- **nwg-look**: GTK theme switcher for Wayland
- **nwg-displays**: Display configuration for Wayland

### Font Configuration
- **Emoji Font**: noto-fonts-emoji

---

## Security & Privacy

### Tor
- **tor**: Anonymity network (installed but not auto-started)

### Firewall
- (Not explicitly configured - default Arch setup)

---

## Additional Configuration Files

### Backup Location
`~/.config/cfg_backups/` - Contains configuration backups

### Dotfiles Management
- Managed via GNU Stow from `~/archyde-prefs/` (git remote: `git@github.com:pranava-mk/archyde-prefs.git`)
- Stow packages:
  - `hyprland` → `~/.config/hypr/CLAUDE.md`, `~/.config/waybar/layouts/pranava-split-pill.jsonc`
  - `claude-global` → `~/.claude/CLAUDE.md`
  - `archyde-issues-fixes` → `~/Documents/archyde-issues-fixes/`
- To re-apply all symlinks: `cd ~/archyde-prefs && stow --target ~ hyprland claude-global archyde-issues-fixes`
- **Waybar**: `pranava-split-pill.jsonc` is the canonical layout — `config.jsonc` is regenerated from it by HyDE's `waybar.py --update`

---

## Installation Script Considerations

### For Future Arch Installation Automation

#### 1. Base System Installation
```bash
# Partition scheme: UEFI with BTRFS
# Boot: EFI partition
# Root: BTRFS with subvolumes (@, @home, @log, @cache)
# Swap: zram-generator (no swap partition needed)
```

#### 2. Package Installation Order

**Phase 1: Base System**
```bash
pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware
pacstrap /mnt intel-ucode btrfs-progs efibootmgr networkmanager
```

**Phase 2: Essential Packages**
```bash
# Install all packages from the "Essential Packages" section
# Use: pacman -S --needed <package-list>
```

**Phase 3: AUR Helper**
```bash
# Install paru
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin && makepkg -si
```

**Phase 4: HyDE Installation**
```bash
# Clone HyDE installer
# Follow: https://github.com/prasanthrangan/hyprdots
```

#### 3. Configuration Deployment

**Copy dotfiles**:
```bash
# .zshrc, .zshenv, .gitconfig
# .config/hypr/ (all Hyprland configs)
# .config/kitty/
# .config/micro/
```

**Install Oh My Zsh**:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**Install shell tools**:
```bash
# Atuin: https://atuin.sh/
# Zoxide: pacman -S zoxide
# Starship: pacman -S starship
# Anifetch: Install via pip/pipx
```

#### 4. Services to Enable
```bash
systemctl enable bluetooth
systemctl enable NetworkManager
systemctl enable sddm
systemctl enable auto-cpufreq
systemctl enable systemd-timesyncd
systemctl enable snapd.socket

systemctl --user enable pipewire.socket
systemctl --user enable pipewire-pulse.socket
systemctl --user enable wireplumber
```

#### 5. Theme Application
```bash
# Copy themes to ~/.themes/ and ~/.local/share/themes/
# Apply Vanta-Black via HyDE theme switcher
# Configure Qt with qt5ct/qt6ct and Kvantum
```

#### 6. Custom Scripts & Binaries
```bash
# Copy scripts to ~/bin/ and ~/.local/bin/
# Ensure they're in PATH
```

#### 7. GRUB Configuration
```bash
# Configure GRUB for dual-boot if needed
# Install theme if desired
grub-mkconfig -o /boot/grub/grub.cfg
```

#### 8. Final Steps
```bash
# Set up Git credentials
# Configure monitors (copy monitors.conf)
# Install browser extensions
# Import bookmarks
# Configure Signal/Telegram
# Set up Docker user permissions
# Configure auto-cpufreq preferences
```

---

## Keybindings Reference

**Note**: `$mainMod` = Super/Windows key

**Quick access**: Press <kbd>Super</kbd> + <kbd>/</kbd> to show keybindings hint in Rofi

### Window Management

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Q</kbd> | Close focused window |
| <kbd>Super</kbd> + <kbd>W</kbd> | Toggle floating |
| <kbd>Super</kbd> + <kbd>G</kbd> | Toggle group |
| <kbd>Super</kbd> + <kbd>F</kbd> | Toggle fullscreen |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd> | Lock screen |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Delete</kbd> | Logout menu |
| <kbd>Alt_R</kbd> + <kbd>Control_R</kbd> | Toggle waybar and reload config |
| <kbd>Super</kbd> + <kbd>X</kbd> | Toggle split |

### Focus Navigation

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>H</kbd> | Focus left |
| <kbd>Super</kbd> + <kbd>J</kbd> | Focus down |
| <kbd>Super</kbd> + <kbd>K</kbd> | Focus up |
| <kbd>Super</kbd> + <kbd>L</kbd> | Focus right |
| <kbd>Alt</kbd> + <kbd>Tab</kbd> | Cycle focus |

### Window Resizing

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>→</kbd> | Resize window right |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd> | Resize window left |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>↑</kbd> | Resize window up |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>↓</kbd> | Resize window down |

### Move Window Across Workspace

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd> | Move active window left |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>→</kbd> | Move active window right |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>↑</kbd> | Move active window up |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>↓</kbd> | Move active window down |

### Mouse Window Management

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Left Click</kbd> | Hold to move window |
| <kbd>Super</kbd> + <kbd>Right Click</kbd> | Hold to resize window |
| <kbd>Super</kbd> + <kbd>Z</kbd> | Hold to move window (keyboard) |
| <kbd>Super</kbd> + <kbd>X</kbd> | Hold to resize window (keyboard) |

### Application Launcher

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Return</kbd> | Terminal emulator (Kitty) |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Return</kbd> | Dropdown terminal |
| <kbd>Super</kbd> + <kbd>E</kbd> | File explorer (yazi in terminal) |
| <kbd>Super</kbd> + <kbd>T</kbd> | Text editor |
| <kbd>Super</kbd> + <kbd>B</kbd> | Web browser |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Escape</kbd> | System monitor |

### Rofi Menus

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Space</kbd> | Application finder |
| <kbd>Super</kbd> + <kbd>Tab</kbd> | Window switcher |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | File finder |
| <kbd>Super</kbd> + <kbd>/</kbd> | Keybindings hint |
| <kbd>Super</kbd> + <kbd>,</kbd> | Emoji picker |
| <kbd>Super</kbd> + <kbd>V</kbd> | Clipboard |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd> | Clipboard manager |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Space</kbd> | Select rofi launcher |

### Hardware Controls - Audio

| Keybinding | Action |
|------------|--------|
| <kbd>F10</kbd> or <kbd>XF86AudioMute</kbd> | Toggle mute output |
| <kbd>F11</kbd> or <kbd>XF86AudioLowerVolume</kbd> | Decrease volume |
| <kbd>F12</kbd> or <kbd>XF86AudioRaiseVolume</kbd> | Increase volume |
| <kbd>XF86AudioMicMute</kbd> | Toggle microphone mute |

### Hardware Controls - Media

| Keybinding | Action |
|------------|--------|
| <kbd>XF86AudioPlay</kbd> / <kbd>XF86AudioPause</kbd> | Play/Pause media |
| <kbd>XF86AudioNext</kbd> | Next media |
| <kbd>XF86AudioPrev</kbd> | Previous media |

### Hardware Controls - Brightness

| Keybinding | Action |
|------------|--------|
| <kbd>XF86MonBrightnessUp</kbd> | Increase brightness |
| <kbd>XF86MonBrightnessDown</kbd> | Decrease brightness |

### Utilities

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>K</kbd> | Toggle keyboard layout |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>G</kbd> | Game mode (disable effects) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> | Open game launcher |

### Screen Capture

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | Color picker (hyprpicker) |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Freeze screen, select region → save + open in satty |
| <kbd>Super</kbd> + <kbd>Print</kbd> | Full screenshot → save + open in satty |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Print</kbd> | Full screen straight to clipboard |

### Theming & Wallpaper

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd> | Next global wallpaper |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>←</kbd> | Previous global wallpaper |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | Select a global wallpaper |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↑</kbd> | Next waybar layout |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>↓</kbd> | Previous waybar layout |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | Wallbash mode selector |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd> | Select a theme |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Y</kbd> | Select animations |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>U</kbd> | Select hyprlock layout |

### Workspace Navigation

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>1</kbd>-<kbd>0</kbd> | Navigate to workspace 1-10 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>→</kbd> | Next workspace |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>←</kbd> | Previous workspace |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>↓</kbd> | Navigate to nearest empty workspace |
| <kbd>Super</kbd> + <kbd>Mouse Wheel Up</kbd> | Previous workspace |
| <kbd>Super</kbd> + <kbd>Mouse Wheel Down</kbd> | Next workspace |

### Move Window to Workspace

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd>-<kbd>0</kbd> | Move to workspace 1-10 |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>→</kbd> | Move window to next relative workspace |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>←</kbd> | Move window to previous relative workspace |

### Special Workspace (Scratchpad)

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>`</kbd> | Toggle scratchpad |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>`</kbd> | Move to scratchpad |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>S</kbd> | Move to scratchpad (silent) |

### Move Window Silently

| Keybinding | Action |
|------------|--------|
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>1</kbd>-<kbd>0</kbd> | Move to workspace 1-10 (silent) |

---

## Quick Reference Commands

### System Maintenance
```bash
# Full system update
paru -Syu

# Clean package cache
paru -Sc

# List explicitly installed packages
pacman -Qe

# List AUR packages
pacman -Qm

# Update mirrors with reflector
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### HyDE/Hyprland
```bash
# Reload Hyprland config
hyprctl reload

# Restart Waybar
systemctl --user restart hyde-Hyprland-bar.service

# Fix wallpaper on DP-1
~/.local/lib/hyde/wallpaper.sh --start --backend swww --global

# Restart hyprdim
pkill hyprdim && hyprdim --strength 0.7 --duration 800 &

# Switch themes
hydectl theme list
hydectl theme set <theme-name>
```

### Development
```bash
# Git commit (as pranava-mk, no co-author)
git add -A && git commit -m "commit message" && git push

# Install global npm package
npm install -g <package>

# Install Python tool with pipx
pipx install <tool>

# Docker without sudo
sudo usermod -aG docker $USER  # Then logout/login
```

### Shell
```bash
# Search command history (Atuin)
# Ctrl+R or just type and use up arrow

# Jump to directory (Zoxide)
z <directory-name>

# Quick file manager
yazi

# System info
fastfetch

# Resource monitor
btop
```

---

## Known Issues & Solutions

### Issue: DP-1 shows black wallpaper after connecting
**Solution**: Run wallpaper script with global flag
```bash
~/.local/lib/hyde/wallpaper.sh --start --backend swww --global
```

### Issue: Duplicate Waybar instances
**Solution**: Restart systemd service instead of launching manually
```bash
pkill waybar  # Kill any manual instances
systemctl --user restart hyde-Hyprland-bar.service
```

### Issue: Window dimming too strong/weak
**Solution**: Adjust hyprdim strength in `~/.config/hypr/hyprland.conf`
```bash
# Edit the exec-once line, change --strength value (0.0-1.0)
exec-once = hyprdim --strength 0.5 --duration 800  # Softer dimming
```

### Issue: Hyprland error notifications won't dismiss
**Solution**: Check for invalid source statements or missing directories in config files
```bash
# Check Hyprland logs for errors
cat /run/user/1000/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/hyprland.log | grep -i error

# Common causes:
# - source statements pointing to non-existent directories
# - Invalid windowrule syntax (e.g., size <85% should be size 85%)

# After fixing, reload Hyprland
hyprctl reload
```

### Issue: Hyprland 0.53 window rules syntax errors (403+ errors)
**Solution**: Hyprland 0.53 completely rewrote window rule syntax. Must convert to new format.

**Symptoms**: Hundreds of "invalid field" errors in windowrules.conf

**Quick fix**: Use modern syntax with `match:` prefix
```bash
# Old syntax (broken in 0.53)
windowrule = float, class:^(firefox)$

# New syntax (0.53+)
windowrule = float true, match:class ^(firefox)$
```

**Full documentation**: `~/Documents/system-issues-fixes/2026-02-13_hyprland-windowrules-syntax-v053.md`

### Issue: Waybar layout reset after theme change
**Resolved** (2026-02-25): Layout is now git-tracked and symlinked — changes persist automatically.

**How it works**:
- Layout file: `~/.config/waybar/layouts/pranava-split-pill.jsonc` → symlink → `~/archyde-prefs/hyprland/.config/waybar/layouts/pranava-split-pill.jsonc`
- HyDE state (`~/.local/state/hyde/staterc`) has `WAYBAR_LAYOUT_PATH` pointing to this file, so it always loads the right layout
- `config.jsonc` is regenerated from the layout file by `waybar.py --update` — edit the layout file, not `config.jsonc`

**To restore on new machine**:
```bash
cd ~/archyde-prefs && stow --target ~ hyprland
~/.local/lib/hyde/waybar.py --set pranava-split-pill
systemctl --user restart hyde-Hyprland-bar.service
```

---

## System Issues Documentation

Critical system issues and their resolutions are documented in:
`~/Documents/archyde-issues-fixes/` → symlinked via stow from `~/archyde-prefs/archyde-issues-fixes/`

This directory is a **separate git repository** — commit new logs after adding them.

```bash
cd ~/Documents/archyde-issues-fixes
git add . && git commit -m "log: <brief description>"
git log --oneline   # view history
```

This directory includes:
- **Boot failures** and recovery procedures
- **Configuration errors** and fixes
- **System upgrade issues** and resolutions
- **Troubleshooting guides** for recurring problems

Each incident is documented with:
- Symptoms and root cause analysis
- Step-by-step resolution procedures
- Lessons learned and prevention strategies
- Verification commands

**Naming convention**: `YYYY-MM-DD_short-description.md`

**When Claude fixes a system issue**, always create a log file here and commit it.

**Recent incidents**:
- `2026-02-13_boot-failure-after-upgrade.md` - Boot crash after kernel upgrade, missing intel-ucode
- `2026-02-13_hyprland-config-errors.md` - Persistent error notifications from invalid source statements
- `2026-02-13_hyprland-windowrules-syntax-v053.md` - 403+ config errors from Hyprland 0.53 syntax rewrite
- `2026-02-20_flameshot-kvantum-crash.md` - Flameshot Kvantum/Wayland crash, switched to grimblast+satty

**Git remote**: set up with `git remote add origin <your-remote>` once you create the repo on GitHub.

---

## Documentation Philosophy

This CLAUDE.md serves as:
1. **System snapshot**: Exact state of current installation
2. **Preferences registry**: All customizations and why they exist
3. **Automation blueprint**: Foundation for installation script
4. **Troubleshooting guide**: Common issues and solutions
5. **Knowledge transfer**: Enable future instances of Claude (or humans) to understand this setup

### Maintenance
- Update this file when making significant system changes
- Document new preferences as they're configured
- Track theme changes if switching away from Vanta-Black
- Note any new AUR packages or custom scripts
- Keep "Known Issues" section current

---

## Future Enhancements

### Planned Improvements
- [ ] Create automated installation script based on this documentation
- [ ] Set up dotfiles repository with version control
- [ ] Add network/firewall hardening configuration
- [ ] Document browser extensions and configurations
- [ ] Create backup/restore scripts for critical configs
- [x] Add keybinding reference (link to HyDE keybindings) ✅
- [ ] Document performance tuning (auto-cpufreq settings)

---

## Resources

- **Arch Wiki**: https://wiki.archlinux.org/
- **HyDE Project**: https://hydeproject.pages.dev/
- **HyDE GitHub**: https://github.com/prasanthrangan/hyprdots
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **AUR**: https://aur.archlinux.org/

---

*Last Updated: 2026-02-06 (keybindings added)*
*System: archy (Arch Linux)*
*User: pranava-mk*
