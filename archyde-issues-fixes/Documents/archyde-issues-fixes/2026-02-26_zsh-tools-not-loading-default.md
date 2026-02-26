# zsh Tools Not Loading in Default Terminal Sessions

**Date**: 2026-02-26
**Status**: Resolved (two-stage investigation)

---

## Symptoms

After opening a new Kitty terminal, the following tools were unavailable unless `source ~/.zshrc` was run manually:

- `atuin` (enhanced shell history, Ctrl+R not working)
- Shell history not using atuin's database
- `~/bin` and `~/.npm-global/bin` missing from `$PATH` (custom scripts and npm globals not accessible)

Note: `zoxide` (`z` command) and standard OMZ features were working fine.

---

## Root Cause (Layer 1): ZDOTDIR redirect bypasses ~/.zshrc

`~/.zshenv` sets `ZDOTDIR=/home/cruxx/.config/zsh`. Once `ZDOTDIR` is set, zsh reads `$ZDOTDIR/.zshrc` for interactive shells — **not** `$HOME/.zshrc`. The `~/.zshrc` file is completely bypassed in every terminal session.

`~/.zshrc` had atuin init, `~/bin` and `~/.npm-global/bin` PATH additions. None of these were running automatically.

### Startup file loading chain (actual, with ZDOTDIR set)

```
zsh starts
  -> reads /etc/zsh/zshenv
  -> reads ~/.zshenv
       sets ZDOTDIR=~/.config/zsh
       sources ~/.config/zsh/.zshenv
         -> sources conf.d/*.zsh
              00-hyde.zsh
                -> sources conf.d/hyde/env.zsh   (always)
                -> sources conf.d/hyde/terminal.zsh  (interactive only)
                     -> sources $ZDOTDIR/user.zsh
                     -> _load_compinit()
                     -> oh-my-zsh sourced
                     -> _load_prompt()
                     -> _load_functions()   <- sources functions/*.zsh
                     -> _load_completions() <- sources completions/*.zsh
  -> reads $ZDOTDIR/.zshrc  (LAST - after all of the above)
```

`~/.zshrc` (Home directory) is never in this chain.

---

## Root Cause (Layer 2): fzf overwrites atuin's Ctrl+R binding

After the first fix put atuin init into `user.zsh`, atuin still wasn't working. The second investigation revealed a **load order collision**:

- `user.zsh` is sourced by `terminal.zsh` **before** `_load_completions()` runs.
- `_load_completions()` sources `completions/fzf.zsh`, which calls `eval "$(fzf --zsh)"`.
- `fzf --zsh` binds Ctrl+R to `fzf-history-widget` in emacs, viins, and vicmd modes.
- This overwrites atuin's `^R → atuin-search` binding that was set moments earlier in `user.zsh`.

Result: Ctrl+R opened fzf history instead of atuin, even though atuin was technically initialized.

Verified by testing load order explicitly:
```zsh
# atuin first, then fzf -> fzf wins
source atuin-init.zsh && eval "$(fzf --zsh)"
bindkey "^R"  # -> "^R" fzf-history-widget

# fzf first, then atuin -> atuin wins
eval "$(fzf --zsh)" && source atuin-init.zsh
bindkey "^R"  # -> "^R" atuin-search
```

The fix: atuin init must live in `$ZDOTDIR/.zshrc`, which zsh reads **after** `terminal.zsh` completes (including `_load_completions`). Atuin then runs last and its Ctrl+R binding sticks.

---

## Fix Applied

**Step 1**: PATH additions placed in `~/.config/zsh/user.zsh` (correct — PATH doesn't have load-order conflicts):

```zsh
export PATH="$HOME/bin:$HOME/.npm-global/bin:$PATH"
```

**Step 2**: Atuin init moved to `~/.config/zsh/.zshrc` (after zoxide, at end of file):

```zsh
_atuin_cache="$HOME/.cache/atuin-init.zsh"
if [[ ! -f "$_atuin_cache" ]] || [[ "$(command -v atuin)" -nt "$_atuin_cache" ]]; then
  atuin init zsh > "$_atuin_cache"
fi
source "$_atuin_cache"
```

The cache pattern (only regenerate when atuin binary is newer than the cached file) avoids running `atuin init zsh` as a subprocess on every shell start.

---

## Files Changed

| File | Change |
|------|--------|
| `~/.config/zsh/user.zsh` | Added PATH additions for `~/bin` and `~/.npm-global/bin`; atuin init removed (was here initially, caused fzf override) |
| `~/.config/zsh/.zshrc` | Added atuin init (cached) at end of file, after zoxide |

`user.zsh` is symlinked from `~/archyde-prefs/hyprland/.config/zsh/user.zsh` (stow-managed).

---

## Verification

Tested with `zsh --interactive --login -c '...'`:

```
=== Ctrl+R binding ===
"^R" atuin-search        <- correct, not fzf-history-widget
=== ATUIN_SESSION ===
ATUIN_SESSION=019c9a5ff4fe7ce1b248e3180896be48
=== PATH check ===
/home/cruxx/bin
/home/cruxx/.npm-global/bin
=== zoxide check ===
__zoxide_z is a shell function from /home/cruxx/.config/zsh/.zshrc
```

After opening a new terminal (no manual sourcing needed):
```zsh
bindkey "^R"                                          # should show atuin-search
echo $PATH | tr ':' '\n' | grep -E 'npm|home.*bin'   # should show ~/bin and ~/.npm-global/bin
atuin history list | head -5                          # should show shell history
z ~                                                   # zoxide jump
```

---

## Lessons Learned

1. When `ZDOTDIR` is set, `$HOME/.zshrc` is never automatically sourced. Only `$ZDOTDIR/.zshrc` is.
2. `$ZDOTDIR/user.zsh` (HyDE's user customization hook) runs **inside** `terminal.zsh`, which means it runs **before** `_load_completions()`. Any tool that registers keybindings and could be overwritten by a later completion script must be initialized in `$ZDOTDIR/.zshrc` instead.
3. `$ZDOTDIR/.zshrc` is the correct place for tools like atuin that set keybindings — it's read by zsh after the entire `terminal.zsh` chain (including completions) has finished.
4. `user.zsh` is appropriate for: plugin list, OMZ overrides, PATH additions, and things that don't depend on load order relative to completions.
5. Do not source `$HOME/.zshrc` from either file — it contains a full OMZ init that conflicts with HyDE's own OMZ loading.

---

## References

- [zsh startup files documentation](https://zsh.sourceforge.io/Intro/intro_3.html)
- [ZDOTDIR in Arch Wiki](https://wiki.archlinux.org/title/Zsh#Startup/Shutdown_files)
- HyDE terminal.zsh: `~/.config/zsh/conf.d/hyde/terminal.zsh`
- HyDE user customization file: `~/.config/zsh/user.zsh`
- fzf completion override: `~/.config/zsh/completions/fzf.zsh`
