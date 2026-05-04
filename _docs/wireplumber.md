# Audio workspace

## What this is for
Tracks WirePlumber ALSA configuration rules for hardware-specific audio fixes. Currently contains one rule fixing Creative Pebble speaker channel swap (physically placed with L/R reversed).

## Folder contents

| Path inside package | Live symlink target | What it controls |
|---|---|---|
| `.config/wireplumber/wireplumber.conf.d/51-swap-headphones-channels.conf` | `~/.config/wireplumber/wireplumber.conf.d/51-swap-headphones-channels.conf` | Swaps L/R channels for Creative Pebble via ALSA |

## Routing table

| Task | Read | Skip |
|---|---|---|
| Debug audio routing | `51-swap-headphones-channels.conf` | — |
| Add new hardware rule | this file for naming convention, then create new `.conf` in same dir | — |

## Conventions
- Rule files: numbered prefix `NN-<description>.conf` — lower number = higher priority.
- After editing: `systemctl --user restart wireplumber` to apply.
- Incident documented in: `~/Documents/archyde-issues-fixes/2026-03-05_creative-pebble-channel-swap.md`

## Available skills
| Skill | When to use |
|---|---|
| `new-task` | Plan a new audio hardware fix |
