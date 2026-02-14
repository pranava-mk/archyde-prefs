# Hyprland Configuration Errors

**Date**: 2026-02-13
**Severity**: Medium (UI partially blocked by error notifications)
**Status**: ✅ Resolved

---

## Symptoms

- Persistent error notifications at top of screen
- Notifications won't dismiss or respond to clicks
- Waybar appears below the error messages
- Error message: `ERR ]: source= globbing error: found no match`

### Visual Impact

The error notifications were blocking the top portion of the screen, making it difficult to see or interact with the top bar and notifications area.

---

## Root Causes

### 1. Missing hypridle Directory (Primary Issue)

**File**: `/home/cruxx/.config/hypr/hypridle.conf:63`

**Problem**:
```conf
source = ./hypridle/*
```

This line tries to source configuration files from `~/.config/hypr/hypridle/` directory, but that directory doesn't exist.

**Why It's a Problem**:
- Hyprland's source statement with wildcard expects at least one file to match
- When no files match, it generates a persistent error notification
- The notification appears at the top of the screen and won't dismiss

**Fix Applied**:
Commented out the problematic source statement since the directory doesn't exist and there are no custom listener configs to load:

```conf
# source = ./hypridle/*  # Commented out - directory doesn't exist, causes error notifications
```

---

### 2. Invalid Windowrules Syntax (Secondary Issue)

**File**: `/home/cruxx/.local/share/hypr/windowrules.conf`
**Lines**: 11, 13

**Problem**:
```conf
windowrule = size <85% <95%,floating:1
windowrule = size <60% <90%,tag:common-popups
```

**Why It's a Problem**:
- Invalid syntax with `<` characters before percentage values
- Correct Hyprland windowrule syntax doesn't use `<` for size specifications
- This would cause errors if the file were sourced

**Fix Applied**:
Removed the `<` characters:

```conf
windowrule = size 85% 95%,floating:1
windowrule = size 60% 90%,tag:common-popups
```

**Note**: This file is in HyDE's template directory (`/.local/share/hypr/`) not the active config directory (`/.config/hypr/`), so it wasn't currently causing errors, but fixing it prevents issues if HyDE regenerates configs.

---

## Resolution Steps

### 1. Fixed hypridle.conf
```bash
# Edited /home/cruxx/.config/hypr/hypridle.conf
# Commented out line 63: source = ./hypridle/*
```

### 2. Fixed windowrules.conf Template
```bash
# Edited /home/cruxx/.local/share/hypr/windowrules.conf
# Fixed lines 11, 13: Removed < characters from size specifications
```

### 3. Reloaded Hyprland
```bash
hyprctl reload
```

### 4. Verified Resolution
- Error notifications disappeared from top of screen
- Waybar displays properly without being blocked
- No error messages in Hyprland logs

---

## Current State

✅ No error notifications blocking the screen
✅ Hyprland loads cleanly without source errors
✅ Waybar displays properly
✅ HyDE template files have correct syntax

---

## Files Modified

### Configuration Fixes
1. `/home/cruxx/.config/hypr/hypridle.conf` - Commented out line 63
2. `/home/cruxx/.local/share/hypr/windowrules.conf` - Fixed lines 11, 13

---

## Related Errors (Not Fixed)

### Waybar "cava" Errors
During Hyprland startup, there are also errors about "cava" module:

```
[ERROR] - cava: [cava:source@3:8-13] cava configuration not found. Create it with 'touch /home/cruxx/.config/cava/cava.conf'
```

**Impact**: None - cava is an audio visualizer module that's optional
**Status**: Informational only, doesn't affect functionality
**Action**: No action needed unless audio visualization is desired

---

## Verification Commands

### Check Hyprland logs for errors
```bash
# View recent errors and warnings
cat /run/user/1000/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/hyprland.log | grep -i "error\|warn" | tail -20

# Should not show "source= globbing error"
```

### Verify Hyprland loads cleanly
```bash
# Reload configuration
hyprctl reload

# Check for visual error notifications - should be none
```

### Check Waybar status
```bash
# Verify Waybar service is running
systemctl --user status hyde-Hyprland-bar.service

# Should show "active (running)"
```

---

## Lessons Learned

1. **Check for missing directories before using source with wildcards**
   - Wildcard source statements expect files to exist
   - Either create the directory or comment out the source line

2. **Validate windowrule syntax**
   - Hyprland windowrule size format: `size WIDTH HEIGHT` (no `<` characters)
   - Use `%` for percentages: `size 85% 95%`
   - See: https://wiki.hyprland.org/Configuring/Window-Rules/

3. **HyDE template files vs active configs**
   - Active configs: `~/.config/hypr/`
   - HyDE templates: `~/.local/share/hypr/`
   - Template errors may not show until theme switcher regenerates configs

4. **Error notifications can be persistent**
   - Some Hyprland errors create notifications that won't dismiss
   - Must fix the underlying issue and reload config to clear them

---

## Prevention for Future

### 1. Create hypridle directory if needed
```bash
# If you want to add custom hypridle listeners in the future:
mkdir -p ~/.config/hypr/hypridle/

# Then uncomment the source line in hypridle.conf
```

### 2. Validate configs before reload
```bash
# Check for syntax errors (Hyprland doesn't have a built-in validator)
# Best practice: test configs in a nested Hyprland session first

# Or grep for common syntax errors:
grep -n "size <" ~/.config/hypr/*.conf  # Should find nothing
```

### 3. Monitor Hyprland logs during startup
```bash
# Watch logs in real-time during reload
tail -f /run/user/1000/hypr/$(echo $HYPRLAND_INSTANCE_SIGNATURE)/hyprland.log
```

---

## References

- [Hyprland Wiki - Window Rules](https://wiki.hyprland.org/Configuring/Window-Rules/)
- [Hyprland Wiki - hypridle](https://wiki.hypr.land/Hypr-Ecosystem/hypridle/)
- [HyDE Project Documentation](https://hydeproject.pages.dev/)

---

*Resolved by: pranava-mk with Claude Code assistance*
*Documented: 2026-02-13*
