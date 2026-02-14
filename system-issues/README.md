# System Issues & Fixes

This directory documents critical system issues, their root causes, and solutions for future reference.

## Purpose

- Track system failures and recovery procedures
- Document configuration errors and fixes
- Enable quick troubleshooting for recurring issues
- Provide reproducible solutions

## Incident Reports

### 2026-02-13
- **[Boot Failure After Upgrade](2026-02-13_boot-failure-after-upgrade.md)** - System wouldn't boot after kernel upgrade, missing intel-ucode in boot entries
- **[Hyprland Config Errors](2026-02-13_hyprland-config-errors.md)** - Persistent error notifications from invalid source statement and windowrules syntax

## How to Use

1. **When encountering a critical issue**: Create a new dated file (e.g., `YYYY-MM-DD_issue-description.md`)
2. **Document**: Include symptoms, root cause, resolution steps, and lessons learned
3. **Update this index**: Add a link to the new incident report

## File Naming Convention

```
YYYY-MM-DD_brief-description.md
```

Examples:
- `2026-02-13_boot-failure-after-upgrade.md`
- `2026-02-13_hyprland-config-errors.md`

## Categories

- **Boot Issues**: Problems preventing system startup
- **Configuration Errors**: Invalid configs causing application failures
- **Package Issues**: Dependency conflicts, package manager problems
- **Hardware Issues**: Driver problems, hardware detection failures
- **Network Issues**: Connectivity, DNS, firewall problems

---

*Last Updated: 2026-02-13*
