# packages/ — System manifest files

Snapshot of all installed packages and enabled systemd units on pranava-mk's machine. Used by `install.sh` to reproduce the full system package set on a fresh Arch install.

This directory is NOT a stow package — files here are not symlinked anywhere.

---

## Manifest files

| File | Contents | Regeneration command |
|---|---|---|
| `pacman-explicit.txt` | All explicitly installed packages (native + AUR) | `pacman -Qqe > packages/pacman-explicit.txt` |
| `pacman-native.txt` | Explicitly installed packages from official repos only | `pacman -Qqen > packages/pacman-native.txt` |
| `pacman-aur.txt` | Explicitly installed AUR/foreign packages only | `pacman -Qqm > packages/pacman-aur.txt` |
| `systemd-system-enabled.txt` | Enabled system-level systemd units | `systemctl list-unit-files --state=enabled --no-legend --no-pager \| awk '{print $1}' > packages/systemd-system-enabled.txt` |
| `systemd-user-enabled.txt` | Enabled user-level systemd units | `systemctl --user list-unit-files --state=enabled --no-legend --no-pager \| awk '{print $1}' > packages/systemd-user-enabled.txt` |

---

## Regenerating manifests

Run all five in sequence after significant package changes:

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

---

## Restore commands (manual, without install.sh)

```bash
# Native packages
sudo pacman -S --needed - < packages/pacman-native.txt

# AUR packages (requires paru)
paru -S --needed - < packages/pacman-aur.txt

# System units
while IFS= read -r unit; do
    [[ "$unit" == *'@.'* ]] && continue   # skip template units
    sudo systemctl enable "$unit" || echo "WARN: $unit"
done < packages/systemd-system-enabled.txt

# User units
while IFS= read -r unit; do
    [[ "$unit" == *'@.'* ]] && continue
    systemctl --user enable "$unit" || echo "WARN: $unit"
done < packages/systemd-user-enabled.txt
```

---

## Machine-specific units

The service manifests include units tied to optional or machine-specific software. These will emit a warning (not an error) on machines where the backing package is not installed:

| Unit | Package | Notes |
|---|---|---|
| `proton.VPN.service` | `proton-vpn-gtk-app` | ProtonVPN GUI app service |
| `tailscaled.service` | `tailscale` | Tailscale VPN daemon |

`install.sh` warns on failure to enable these but does not abort.

Template units (e.g. `getty@.service`) are skipped automatically — they require an instance name and cannot be enabled generically.
