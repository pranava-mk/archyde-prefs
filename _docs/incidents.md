# Incident logs workspace

## What this is for
Tracks system issue documentation — each file records a specific failure, its root cause, resolution steps, and prevention. Used as institutional memory for recurring problems and fresh-install troubleshooting.

## Folder contents

| File | Incident |
|---|---|
| `2026-02-13_boot-failure-after-upgrade.md` | Boot crash after kernel upgrade, missing intel-ucode |
| `2026-02-13_hyprland-config-errors.md` | Persistent error notifications from invalid source statements |
| `2026-02-13_hyprland-windowrules-syntax-v053.md` | 400+ config errors from Hyprland 0.53 syntax rewrite |
| `2026-02-20_flameshot-kvantum-crash.md` | Flameshot Kvantum/Wayland crash — switched to grimblast+satty |
| `2026-02-26_zsh-tools-not-loading-default.md` | fzf/atuin not loading — ZDOTDIR + load order root cause |
| `2026-03-05_creative-pebble-channel-swap.md` | Creative Pebble speakers L/R reversed — fixed via WirePlumber ALSA |
| `2026-07-10_ani-cli-aa-crypto-missing.md` | ani-cli "no valid sources" — AllAnime aaReq crypto change (PR #1772) + history corruption fix |

## Routing table

| Task | Read | Skip |
|---|---|---|
| Investigate a recurring issue | matching dated log | unrelated logs |
| Write new incident log | `README.md` in this folder for format reference | — |
| Fresh install troubleshooting | all logs chronologically | — |

## Conventions
- Naming: `YYYY-MM-DD_short-description.md`.
- Live path: `~/Documents/archyde-issues-fixes/` (stow symlink).
- After adding a log: `cd ~/archyde-prefs && git add archyde-issues-fixes/ && git commit && git push`. This folder is a stow package **inside** `archyde-prefs` — it is NOT a separate repo.
- Each log must contain: symptoms, root cause, resolution steps, verification commands.

## Available skills
| Skill | When to use |
|---|---|
| `new-task` | Plan investigation of a new system issue |
