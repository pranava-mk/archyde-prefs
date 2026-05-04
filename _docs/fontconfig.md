# Fonts workspace

## What this is for
Tracks fontconfig rules that wire Noto script-specific font families into the system fallback chain. Without these rules, browsers show tofu (□) for scripts not covered by `Noto Sans` (Latin-only base).

## Folder contents

| Path inside package | Live symlink target | What it controls |
|---|---|---|
| `.config/fontconfig/conf.d/70-noto-indic-fallback.conf` | `~/.config/fontconfig/conf.d/70-noto-indic-fallback.conf` | Adds Noto Indic/script fonts to sans-serif/serif/monospace fallback |

## Scripts covered by current rules
Telugu, Kannada, Tamil, Malayalam, Devanagari, Bengali, Gujarati, Gurmukhi, Arabic, Hebrew, Thai, Georgian, Armenian.

## Routing table

| Task | Read | Skip |
|---|---|---|
| Add fallback for new script | `70-noto-indic-fallback.conf` | — |
| Debug tofu in browser | run `fc-match "sans-serif:charset=<codepoint>"` to verify routing | — |
| Install new font package | `paru -S <package>` then `fc-cache -fv` | this repo (no change needed unless adding rules) |

## Conventions
- Rule numbering: `70-*` runs after system Noto rules (`66-noto-sans.conf`).
- Use `accept` (not `prefer`) to append script fonts after `Noto Sans` — preserves Latin priority.
- After any change: `fc-cache -fv` + restart browser (full quit, not new window).

## Available skills
| Skill | When to use |
|---|---|
| `new-task` | Plan font coverage expansion |
