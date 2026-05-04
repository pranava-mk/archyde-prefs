# Claude workspace

## What this is for
Tracks the global Claude Code config (`~/.claude/CLAUDE.md`) — the system snapshot, preferences, keybindings reference, and known issues doc that all Claude Code sessions on this machine load automatically.

## Folder contents

| Path inside package | Live symlink target | What it controls |
|---|---|---|
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Global Claude Code instructions, system docs, keybindings |

## Routing table

| Task | Read | Skip |
|---|---|---|
| Update system docs after config change | `~/.claude/CLAUDE.md` directly (symlink writes through) | — |
| Add known issue | `~/.claude/CLAUDE.md` Known Issues section | — |
| Change Claude behaviour globally | `~/.claude/CLAUDE.md` Claude Behavior Instructions section | — |

## Conventions
- Edit at `~/.claude/CLAUDE.md` — symlink writes through to this repo automatically.
- After editing: `cd ~/archyde-prefs && git add -A && git commit && git push`.
- This file is loaded by Claude Code on every session start — keep it accurate and current.

## Available skills
| Skill | When to use |
|---|---|
| `organise-workspace` | Restructure this repo |
| `new-task` | Plan a multi-step system change |
| `caveman` | Compressed communication mode |
