# Boot Failure After System Upgrade

**Date**: 2026-02-13
**Severity**: Critical (system wouldn't boot)
**Status**: ✅ Resolved

---

## Symptom

System failed to boot after running system upgrade (`pacman -Syu`). The newer kernel would not start properly, leaving the system in an unbootable state.

---

## Root Cause

System upgraded to newer kernel (**linux 6.16.5.arch1-1**) but boot entries didn't include **intel-ucode** microcode package in the initrd, causing boot failure.

### Why This Happened

- The upgrade installed a new kernel version
- New boot entries were created automatically
- The entries didn't include the intel-ucode package that's critical for Intel CPUs
- Without microcode updates, the kernel failed to boot properly

---

## Recovery Steps Taken

### 1. Booted into Alternative Kernel
- Selected **linux-lts 6.12.70-1** from boot menu
- LTS kernel still had working configuration

### 2. Added intel-ucode to Boot Entries

Modified the following boot entry files to include intel-ucode:

**File**: `/boot/loader/entries/arch-lts.conf`
```conf
initrd /intel-ucode.img
initrd /initramfs-linux-lts.img
```

**File**: `/boot/loader/entries/2025-09-09_12-59-15_linux.conf`
```conf
initrd /intel-ucode.img
initrd /initramfs-linux.img
```

**File**: `/boot/loader/entries/2025-09-09_12-59-15_linux-fallback.conf`
```conf
initrd /intel-ucode.img
initrd /initramfs-linux-fallback.img
```

### 3. Configured systemd-boot Default Entry

Set LTS kernel as default boot option for reliability:

**File**: `/boot/loader/loader.conf`
```conf
default arch-lts.conf
```

### 4. Verified Configuration

```bash
bootctl status
```

Confirmed:
- intel-ucode is loaded in initrd
- LTS kernel is default
- All boot entries are valid

---

## Current State

✅ System boots properly on LTS kernel
✅ intel-ucode properly loaded
✅ systemd-boot configured correctly
✅ Can switch to newer kernel if needed (both have intel-ucode now)

---

## Lessons Learned

1. **Always ensure intel-ucode is in all boot entry configurations**
   - Intel CPUs require microcode updates to boot properly
   - Each boot entry must explicitly reference intel-ucode

2. **Keep LTS kernel as fallback option**
   - Provides stable recovery path when newer kernels fail
   - Should always be installed and configured

3. **Verify boot entries after kernel upgrades**
   - Check `/boot/loader/entries/` for new entries
   - Ensure all entries include necessary initrd images
   - Test boot before rebooting into new kernel

4. **Use systemd-boot for clear boot management**
   - systemd-boot (bootctl) provides simpler configuration than GRUB
   - Easier to troubleshoot and verify

---

## Related Files

### Boot Configuration
- `/boot/loader/loader.conf` - bootctl default settings
- `/boot/loader/entries/arch-lts.conf` - LTS kernel entry
- `/boot/loader/entries/2025-09-09_12-59-15_linux.conf` - Main kernel entry
- `/boot/loader/entries/2025-09-09_12-59-15_linux-fallback.conf` - Fallback entry

### Verification Commands
```bash
# Check boot status
bootctl status

# List boot entries
bootctl list

# View specific entry
cat /boot/loader/entries/arch-lts.conf

# Check if intel-ucode is installed
pacman -Q intel-ucode
```

---

## Prevention for Future

1. **Create a bootctl verification script**:
   ```bash
   #!/bin/bash
   # Check all boot entries have intel-ucode
   for entry in /boot/loader/entries/*.conf; do
       if ! grep -q "intel-ucode" "$entry"; then
           echo "WARNING: $entry missing intel-ucode"
       fi
   done
   ```

2. **Add pacman hook to verify boot entries after kernel updates**
   - Could create `/etc/pacman.d/hooks/check-boot-entries.hook`

3. **Keep both kernels updated**:
   ```bash
   # Update both standard and LTS kernels
   sudo pacman -S linux linux-lts linux-headers linux-lts-headers
   ```

---

## References

- [Arch Wiki - systemd-boot](https://wiki.archlinux.org/title/Systemd-boot)
- [Arch Wiki - Microcode](https://wiki.archlinux.org/title/Microcode)
- [Arch Wiki - Intel](https://wiki.archlinux.org/title/Intel)

---

*Resolved by: pranava-mk*
*Documented: 2026-02-13*
