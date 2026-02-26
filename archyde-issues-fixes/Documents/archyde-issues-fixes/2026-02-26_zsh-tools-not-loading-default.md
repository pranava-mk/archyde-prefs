# zsh Tools Not Loading in Default Terminal Sessions

**Date**: 2026-02-26
**Status**: Resolved

---

## Symptoms

After opening a new Kitty terminal, the following tools were unavailable unless `source ~/.zshrc` was run manually:

- `atuin` (enhanced shell history, Ctrl+R not working)
- Shell history not using atuin's database
- `~/bin` and `~/.npm-global/bin` missing from `$PATH` (custom scripts and npm globals not accessible)

Note: `zoxide` (`z` command) and standard OMZ features were working fine via HyDE's config.

---

## Root Cause

`~/.zshenv` sets `ZDOTDIR=/home/cruxx/.config/zsh`. This is a standard zsh mechanism for relocating config files out of `$HOME`.

The side effect: once `ZDOTDIR` is set, zsh reads `$ZDOTDIR/.zshrc` (i.e. `~/.config/zsh/.zshrc`) for interactive shells — **not** `$HOME/.zshrc`. The `~/.zshrc` file is completely bypassed in normal terminal sessions.

### Startup file loading chain (actual, with ZDOTDIR set)

```
zsh starts
  -> reads /etc/zsh/zshenv
  -> reads ~/.zshenv
       sets ZDOTDIR=~/.config/zsh
       sources ~/.config/zsh/.zshenv
         -> sources conf.d/*.zsh
              00-hyde.zsh -> sources conf.d/hyde/terminal.zsh (HyDE zsh setup)
              terminal.zsh -> sources $ZDOTDIR/user.zsh (user customizations)
  -> reads $ZDOTDIR/.zshrc (~/.config/zsh/.zshrc)
       only had: eval "$(zoxide init zsh)" and export EDITOR=code
```

`~/.zshrc` (which had atuin init, OMZ setup, `~/bin` and `~/.npm-global/bin` PATH additions) was **never sourced automatically**.

### Why `source ~/.zshrc` "fixed" it temporarily

Running `source ~/.zshrc` manually loaded the `~/.zshrc` file in the current session, which initialized atuin and fixed PATH. But this was never automatic — every new terminal required it.

### Why zoxide worked but atuin didn't

`zoxide` was already initialized in `~/.config/zsh/.zshrc` (line 46: `eval "$(zoxide init zsh)"`), so it was part of the auto-loaded HyDE chain.

`atuin` was only initialized in `~/.zshrc` (lines 80-84), which was never auto-sourced.

`~/bin` and `~/.npm-global/bin` were only added to `PATH` in `~/.zshrc` (lines 2 and 138), so custom scripts in `~/bin/` and global npm packages were inaccessible by default.

---

## Fix Applied

Added the missing initializations to `~/.config/zsh/user.zsh`. This is HyDE's designated user customization file — it is sourced by `terminal.zsh` as part of the standard HyDE startup chain, so anything placed here loads in every interactive terminal session.

**File modified**: `/home/cruxx/.config/zsh/user.zsh`

Added to the bottom of the file:

```zsh
# PATH additions
# ~/bin and ~/.npm-global/bin are not added by HyDE's env.zsh, so we add them here.
# Note: ZDOTDIR is set to ~/.config/zsh, so ~/.zshrc is not sourced automatically.
export PATH="$HOME/bin:$HOME/.npm-global/bin:$PATH"

# Atuin - enhanced shell history
# ~/.zshrc is never auto-sourced (ZDOTDIR redirect), so we initialize atuin here.
# Using the same cache pattern as ~/.zshrc for performance.
_atuin_cache="$HOME/.cache/atuin-init.zsh"
if [[ ! -f "$_atuin_cache" ]] || [[ "$(command -v atuin)" -nt "$_atuin_cache" ]]; then
  atuin init zsh > "$_atuin_cache"
fi
source "$_atuin_cache"
```

The atuin cache pattern (write init output to `~/.cache/atuin-init.zsh`, only regenerate when atuin binary is newer) avoids running `atuin init zsh` as a subprocess on every shell start — consistent with how `~/.zshrc` handled it.

---

## Why NOT source ~/.zshrc from user.zsh

`~/.zshrc` still contains a full OMZ setup (`source $ZSH/oh-my-zsh.sh`). HyDE's `terminal.zsh` already loads OMZ and plugins. Sourcing `~/.zshrc` on top of HyDE's chain would double-initialize OMZ, cause plugin conflicts, and significantly slow down shell startup. The correct approach is to place only the missing pieces into `user.zsh`.

---

## Files Changed

| File | Change |
|------|--------|
| `~/.config/zsh/user.zsh` | Added atuin init (cached) and PATH additions for `~/bin` and `~/.npm-global/bin` |

---

## Verification

After the fix, opening a new terminal automatically has:
- `~/bin` and `~/.npm-global/bin` in `$PATH`
- Atuin Ctrl+R history search working immediately
- Zoxide `z` command working (was already working via `~/.config/zsh/.zshrc`)

Test in a new terminal (no manual sourcing needed):
```zsh
echo $PATH | tr ':' '\n' | grep -E 'npm|home.*bin'   # should show ~/bin and ~/.npm-global/bin
atuin history list | head -5                            # should show shell history
z ~                                                     # zoxide jump (should work)
```

---

## Lessons Learned

- When `ZDOTDIR` is set in `~/.zshenv`, `$HOME/.zshrc` is **never** automatically sourced by zsh. Only `$ZDOTDIR/.zshrc` is.
- In HyDE's zsh setup, `$ZDOTDIR/user.zsh` is the correct place for user customizations — it's sourced by `terminal.zsh` inside the HyDE startup chain.
- Any tool initialization that was historically put in `~/.zshrc` must be duplicated in `$ZDOTDIR/user.zsh` (or `$ZDOTDIR/.zshrc`) when HyDE's ZDOTDIR redirect is active.
- Do not source `~/.zshrc` from `user.zsh` — it contains OMZ initialization that conflicts with HyDE's own OMZ loading.

---

## References

- [zsh startup files documentation](https://zsh.sourceforge.io/Intro/intro_3.html)
- [ZDOTDIR in Arch Wiki](https://wiki.archlinux.org/title/Zsh#Startup/Shutdown_files)
- HyDE zsh config: `~/.config/zsh/conf.d/hyde/terminal.zsh`
- User customization file: `~/.config/zsh/user.zsh`
