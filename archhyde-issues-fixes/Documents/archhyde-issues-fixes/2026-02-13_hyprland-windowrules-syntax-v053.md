# Hyprland 0.53 Window Rules Syntax Breaking Changes

**Date**: 2026-02-13
**Issue**: Config errors in windowrules.conf after Hyprland 0.53 update
**Severity**: High - 403+ config parsing errors preventing proper window management
**Status**: ✅ Resolved

---

## Symptoms

After running Hyprland 0.53.3, persistent error notifications appeared on every `hyprctl reload`:

```
Config error in file /home/cruxx/.config/hypr/windowrules.conf at line 15: invalid field float: missing a value
Config error in file /home/cruxx/.config/hypr/windowrules.conf at line 16: invalid field title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$: missing a value
Config error in file /home/cruxx/.config/hypr/windowrules.conf at line 17: invalid field title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$: missing a value
Config error in file /home/cruxx/.config/hypr/windowrules.conf at line 18: invalid field pin: missing a value
Config error in file /home/cruxx/.config/hypr/windowrules.conf at line 20: invalid field class:^(firefox)$: missing a value
(403 more...)
```

---

## Root Cause

**Hyprland 0.53** introduced a **complete rewrite of window rule syntax**. The old syntax is no longer compatible and causes parsing errors.

### Breaking Changes

1. **Matchers require `match:` prefix**
2. **Boolean properties need explicit values**
3. **`idleinhibit` was removed** (replaced with `idle_inhibit fullscreen`)
4. **`windowrulev2` was deprecated** (merged into `windowrule`)
5. **`initialTitle` matcher removed** (use `title` instead)
6. **`keepaspectratio` field removed**
7. **Layer rules require `match:namespace` prefix**

---

## Syntax Comparison

### Old Syntax (Pre-0.53)

```conf
# Matchers without prefix
windowrule = float, class:^(firefox)$
windowrule = opacity 0.90 $& 0.90 $& 1, class:^(firefox)$
windowrule = pin, title:^(Picture-in-Picture)$

# Old idleinhibit (removed)
windowrule = idleinhibit fullscreen, class:^(.*mpv.*)$

# windowrulev2 (deprecated)
windowrulev2 = float, class:^(firefox)$

# initialTitle matcher
windowrule = opacity 0.70, initialTitle:^(Spotify Free)$

# Layer rules without prefix
layerrule = blur, rofi
layerrule = ignorezero, rofi
```

### New Syntax (0.53+)

```conf
# Matchers WITH match: prefix
windowrule = float true, match:class ^(firefox)$
windowrule = opacity 0.90 $& 0.90 $& 1, match:class ^(firefox)$
windowrule = pin true, match:title ^(Picture-in-Picture)$

# New idle_inhibit syntax
windowrule = idle_inhibit fullscreen true, match:class ^(.*mpv.*)$

# Use windowrule (not windowrulev2)
windowrule = float true, match:class ^(firefox)$

# Use title instead of initialTitle
windowrule = opacity 0.70, match:title ^(Spotify Free)$

# Layer rules WITH match:namespace prefix
layerrule = blur true, match:namespace rofi
layerrule = ignore_alpha 0, match:namespace rofi
```

---

## Key Syntax Rules

### 1. Matcher Format

**Format**: `match:<type> <pattern>`

**Types**:
- `match:class` - Window class
- `match:title` - Window title
- `match:floating` - Floating state
- `match:fullscreen` - Fullscreen state

**Examples**:
```conf
windowrule = float true, match:class ^(kitty)$
windowrule = opacity 0.8, match:title ^(Firefox)$
windowrule = float true, match:class ^(dolphin)$ match:title ^(Copying)$
```

### 2. Boolean Properties

Properties like `float`, `pin`, `fullscreen` need explicit `true` or `false` values:

```conf
# Correct
windowrule = float true, match:class ^(vlc)$
windowrule = pin true, match:title ^(Picture-in-Picture)$

# Wrong (old syntax)
windowrule = float, match:class ^(vlc)$
windowrule = pin, match:title ^(Picture-in-Picture)$
```

### 3. Opacity Format

```conf
windowrule = opacity <active> $& <inactive> $& <fullscreen>, match:class <pattern>

# Example
windowrule = opacity 0.90 $& 0.90 $& 1, match:class ^(firefox)$
```

The `$&` is HyDE's shorthand for `override`.

### 4. Layer Rules

```conf
layerrule = <property> <value>, match:namespace <namespace>

# Examples
layerrule = blur true, match:namespace rofi
layerrule = ignore_alpha 0, match:namespace notifications
```

### 5. Multiple Matchers

Use space to separate multiple match conditions:

```conf
windowrule = float true, match:class ^(dolphin)$ match:title ^(Progress Dialog)$
```

---

## Resolution Steps

### Step 1: Backed Up Original Config

```bash
cp ~/.config/hypr/windowrules.conf ~/.config/hypr/windowrules.conf.backup
```

### Step 2: Rewrote All Window Rules

Converted entire `windowrules.conf` to Hyprland 0.53+ syntax:

1. ✅ Added `match:` prefix to all matchers
2. ✅ Added `true` values to boolean properties (`float`, `pin`)
3. ✅ Replaced `idleinhibit fullscreen` with `idle_inhibit fullscreen true`
4. ✅ Removed `keepaspectratio` (invalid field)
5. ✅ Changed `initialTitle` to `title`
6. ✅ Updated layer rules with `match:namespace` prefix
7. ✅ Added explicit values to layer rule properties

### Step 3: Applied and Verified

```bash
hyprctl reload
# Output: ok (no errors)
```

---

## Fixed Configuration

**Location**: `~/.config/hypr/windowrules.conf`

### Idle Inhibit Rules

```conf
# Prevent screen from sleeping for media players
windowrule = idle_inhibit fullscreen true, match:class ^(.*celluloid.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*mpv.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*vlc.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*[Ss]potify.*)$

# Prevent screen from sleeping for browsers in fullscreen
windowrule = idle_inhibit fullscreen true, match:class ^(.*brave-browser.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*firefox.*)$
windowrule = idle_inhibit fullscreen true, match:class ^(.*chromium.*)$
```

### Picture-in-Picture

```conf
windowrule = float true, match:title ^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
windowrule = move 73% 72%, match:title ^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
windowrule = size 25%, match:title ^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
windowrule = pin true, match:title ^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$
```

### Opacity Rules

```conf
# Browsers
windowrule = opacity 0.90 $& 0.90 $& 1, match:class ^(firefox)$
windowrule = opacity 0.90 $& 0.90 $& 1, match:class ^(brave-browser)$

# Editors
windowrule = opacity 0.80 $& 0.80 $& 1, match:class ^([Cc]ode)$
windowrule = opacity 0.80 $& 0.80 $& 1, match:class ^(kitty)$

# Gaming
windowrule = opacity 0.70 $& 0.70 $& 1, match:class ^([Ss]team)$
windowrule = opacity 0.70 $& 0.70 $& 1, match:title ^(Spotify Free)$
```

### Float Rules

```conf
# System utilities
windowrule = float true, match:class ^(vlc)$
windowrule = float true, match:class ^(org.pulseaudio.pavucontrol)$
windowrule = float true, match:class ^(blueman-manager)$

# Multi-condition rules
windowrule = float true, match:class ^(org.kde.dolphin)$ match:title ^(Progress Dialog — Dolphin)$
windowrule = float true, match:class ^(firefox)$ match:title ^(Picture-in-Picture)$

# Common modals
windowrule = float true, match:title ^(Open)$
windowrule = float true, match:title ^(Save As)$
windowrule = float true, match:title ^(File Upload)(.*)$
```

### Layer Rules

```conf
# Rofi
layerrule = blur true, match:namespace rofi
layerrule = ignore_alpha 0, match:namespace rofi

# Notifications
layerrule = blur true, match:namespace notifications
layerrule = ignore_alpha 0, match:namespace notifications

# SWAYNC
layerrule = blur true, match:namespace swaync-notification-window
layerrule = ignore_alpha 0, match:namespace swaync-notification-window
layerrule = blur true, match:namespace swaync-control-center
layerrule = ignore_alpha 0, match:namespace swaync-control-center

# Logout dialog
layerrule = blur true, match:namespace logout_dialog
```

---

## Verification Commands

```bash
# Check for config errors
hyprctl reload

# View current window rules
hyprctl windowrules

# Test a specific rule
hyprctl setprop address:0x... float true  # Replace with actual window address
```

---

## References

- **Hyprland 0.53 Release Notes**: https://hypr.land/news/update53/
- **Official Window Rules Wiki**: https://wiki.hypr.land/Configuring/Window-Rules/
- **HyDE Project windowrules.conf**: https://github.com/HyDE-Project/HyDE/blob/master/Configs/.config/hypr/windowrules.conf
- **Syntax Discussion**: https://github.com/hyprwm/Hyprland/discussions/13115

---

## Lessons Learned

1. **Major version updates can break config syntax completely**
   - Always backup configs before updates
   - Check release notes for breaking changes

2. **Hyprland 0.53 rewrote window rules from scratch**
   - Old syntax is incompatible
   - All rules must be manually converted

3. **HyDE auto-generated configs may need manual fixes**
   - Theme switcher may generate old syntax
   - Personal customizations should be version-controlled

4. **Config validation is important**
   - Run `hyprctl reload` after changes
   - Check for errors immediately

---

## Prevention

### Future Hyprland Updates

Before updating Hyprland:
1. Backup current working config
2. Check release notes for breaking changes
3. Review wiki for syntax updates
4. Test in a separate config first

### Version Control

Git-track Hyprland configs:
```bash
cd ~/.config/hypr
git add windowrules.conf
git commit -m "Working windowrules for Hyprland 0.53"
```

### Automated Backups

HyDE automatically creates backups in `~/.config/cfg_backups/` when switching themes. Restore with:
```bash
# List backups
ls -lt ~/.config/cfg_backups/

# Restore a backup
cp ~/.config/cfg_backups/YYMMDD_HHhMMmSSs/.config/hypr/windowrules.conf ~/.config/hypr/
hyprctl reload
```

---

**Resolution Date**: 2026-02-13
**Time to Fix**: ~45 minutes (research + rewrite + testing)
**Status**: ✅ Complete - All 403+ errors resolved
