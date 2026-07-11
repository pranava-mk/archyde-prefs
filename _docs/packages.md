# packages workspace

## What this is for
Stores snapshots of all installed packages and enabled systemd units on pranava-mk's machine. These manifests drive `install.sh` for full system reproduction on a fresh Arch install.

`packages/` is NOT a stow package — nothing here is symlinked into `~/`.

## Folder contents

| File | Contents |
|---|---|
| `pacman-explicit.txt` | All explicitly installed packages (native + AUR combined) |
| `pacman-native.txt` | Official-repo packages only — fed to `pacman -S --needed` on restore |
| `pacman-aur.txt` | AUR/foreign packages only — fed to `paru -S --needed` on restore |
| `systemd-system-enabled.txt` | Enabled system-level (`/etc/systemd/system/`) units |
| `systemd-user-enabled.txt` | Enabled user-level (`~/.config/systemd/user/`) units |
| `README.md` | Manifest docs, exact regeneration commands, restore commands, machine-specific unit notes |

## Regeneration workflow

Run after significant package changes (`paru -Syu`, new installs, removals):

```bash
cd ~/archyde-prefs

pacman -Qqe  > packages/pacman-explicit.txt
pacman -Qqen > packages/pacman-native.txt
pacman -Qqm  > packages/pacman-aur.txt

systemctl list-unit-files --state=enabled --no-legend --no-pager \
    | awk '{print $1}' > packages/systemd-system-enabled.txt

systemctl --user list-unit-files --state=enabled --no-legend --no-pager \
    | awk '{print $1}' > packages/systemd-user-enabled.txt

git add packages/
git commit -m "chore: update package manifests"
git push
```

## Routing table

| Task | Read | Skip |
|---|---|---|
| Reproduce full system packages on new machine | `README.md`, then use `install.sh` | — |
| Check what was installed | `pacman-explicit.txt` | — |
| Debug a missing service | `systemd-system-enabled.txt` or `systemd-user-enabled.txt` | — |
| Update manifests after package changes | regeneration workflow above | — |

## Conventions

- `pacman-native.txt` and `pacman-aur.txt` are mutually exclusive subsets of `pacman-explicit.txt`.
- Template units (e.g. `getty@.service`) in the systemd manifests are skipped by `install.sh` — they require an instance name and cannot be enabled generically.
- Machine-specific units (`proton.VPN.service`, `tailscaled.service`) are included in the manifest but will warn (not abort) on machines without those packages installed.
