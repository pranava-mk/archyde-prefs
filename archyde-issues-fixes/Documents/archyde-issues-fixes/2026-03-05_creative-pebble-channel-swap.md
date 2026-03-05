# Creative Pebble Speaker Channel Swap via WirePlumber

**Date**: 2026-03-05
**System**: archy (Arch Linux / HyDE / Hyprland)
**Category**: Audio / Hardware Setup

---

## Situation

**Hardware**: Creative Pebble V3 speakers — main unit (right channel) + satellite (right-to-left cable).

**Physical placement**: The cable only reaches comfortably with the main unit on the right and the satellite on the left. However:
- Main unit = Right channel output
- Satellite = Left channel output

Result: left ear hears right channel, right ear hears left channel — stereo completely flipped.

---

## Root Cause

Physical cable length forced a speaker arrangement that conflicts with the electrical channel assignment. Moving the speakers is impractical.

---

## Solution

Override `audio.position` on the headphones ALSA output node via WirePlumber rules. By labeling the hardware channels as `[FR FL]` instead of `[FL FR]`, PipeWire routes:
- App FL → hardware channel 1 (physically right = correct)
- App FR → hardware channel 0 (physically left = correct)

This is a pure software label swap — zero signal processing overhead, no virtual sink, transparent to all applications.

---

## Implementation

**File created**: `~/.config/wireplumber/wireplumber.conf.d/51-swap-headphones-channels.conf`

```conf
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "~alsa_output.*Headphones.*"
      }
    ]
    actions = {
      update-props = {
        audio.channels = 2
        audio.position = [ FR FL ]
      }
    }
  }
]
```

**Applied with**:
```bash
systemctl --user restart wireplumber
```

---

## Verification

Test before/after with:
```bash
speaker-test -t sine -c 2 -s 1   # "Front Left" should come from physical left speaker
```

Or play stereo content (music with obvious panning) and confirm imaging is correct.

---

## Reverting

```bash
rm ~/.config/wireplumber/wireplumber.conf.d/51-swap-headphones-channels.conf
systemctl --user restart wireplumber
```

---

## Notes

- WirePlumber version: 0.5.13
- PipeWire version: 1.4.10
- The match pattern `~alsa_output.*Headphones.*` targets the Intel HDA headphones output (the 3.5mm jack / USB speaker output recognized as headphones)
- If a different audio output device is added later and also matches "Headphones", it will also be channel-swapped — unlikely but worth noting
