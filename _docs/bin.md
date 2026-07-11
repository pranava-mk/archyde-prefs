# bin workspace

## What this is for
Tracks user-authored scripts that live in `~/bin/`. These are local executables not provided by any package manager — scripts that set up sandboxes, wrap tools, or automate one-off tasks specific to this machine.

## Folder contents

| File (repo path) | Live path | Purpose |
|---|---|---|
| `bin/bin/openclaw-sandbox` | `~/bin/openclaw-sandbox` | Launches the OpenClaw game inside a Bubblewrap sandbox |
| `bin/bin/setup-openclaw-sandbox` | `~/bin/setup-openclaw-sandbox` | One-time setup script for the OpenClaw sandbox environment |

## Deliberately untracked

| File | Reason |
|---|---|
| `~/bin/ani-cli` | Patched upstream binary — a modified version of the ani-cli AUR package with a fix for the AllAnime `aaReq` crypto API change. The patch is documented in `archyde-issues-fixes/2026-07-10_ani-cli-aa-crypto-missing.md`. Tracking the binary itself is not useful; the incident log records how to reproduce the patch on a new machine. |

## Routing table

| Task | Read | Skip |
|---|---|---|
| Run OpenClaw | `bin/bin/setup-openclaw-sandbox` (first time), then `bin/bin/openclaw-sandbox` | — |
| Reproduce ani-cli patch on new machine | `~/Documents/archyde-issues-fixes/2026-07-10_ani-cli-aa-crypto-missing.md` | — |

## Conventions

- Scripts here must be executable (`chmod +x`) before stowing.
- `~/bin/` is on PATH via `shell/.config/zsh/.zshenv` (or `user.zsh`).
- Do not track downloaded binaries (zed, anifetch) or AUR-installed wrappers — they reinstall via package managers.
