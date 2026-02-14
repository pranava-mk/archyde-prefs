# System Documentation Repository

Centralized documentation for Arch Linux system configuration and troubleshooting.

**Owner**: pranava-mk
**System**: archy (Arch Linux)
**Last Updated**: 2026-02-13

---

## Structure

```
docs-repo/
├── hyprland/          # Hyprland configuration documentation
├── system-issues/     # System issue documentation and fixes
└── claude-global/     # Global Claude Code configuration
```

---

## Symlink Setup

This repository contains the actual documentation files. Symlinks point from their original locations:

### Hyprland Configuration
- **Repository**: `~/docs-repo/hyprland/CLAUDE.md`
- **Symlink**: `~/.config/hypr/CLAUDE.md` → `~/docs-repo/hyprland/CLAUDE.md`

### System Issues
- **Repository**: `~/docs-repo/system-issues/*.md`
- **Symlink**: `~/Documents/system-issues-fixes/*.md` → `~/docs-repo/system-issues/*.md`

### Claude Global Config
- **Repository**: `~/docs-repo/claude-global/CLAUDE.md`
- **Symlink**: `~/.claude/CLAUDE.md` → `~/docs-repo/claude-global/CLAUDE.md`

---

## Usage

### Making Changes

Edit files in their original locations (symlinks will update the repo files):

```bash
# Edit Hyprland docs
micro ~/.config/hypr/CLAUDE.md

# Edit global Claude config
micro ~/.claude/CLAUDE.md

# Add new system issue
micro ~/Documents/system-issues-fixes/2026-XX-XX_new-issue.md
```

### Syncing Changes

```bash
cd ~/docs-repo

# Check what changed
git status
git diff

# Commit changes
git add -A
git commit -m "Update documentation"

# Push to remote (if configured)
git push
```

---

## Git Remote Setup

To sync with GitHub/GitLab:

```bash
cd ~/docs-repo

# Add remote repository
git remote add origin git@github.com:pranava-mk/arch-docs.git

# Push to remote
git branch -M main
git push -u origin main
```

---

## Restore from Repository

If reinstalling or setting up on another machine:

```bash
# Clone repository
git clone git@github.com:pranava-mk/arch-docs.git ~/docs-repo

# Create symlinks
ln -sf ~/docs-repo/hyprland/CLAUDE.md ~/.config/hypr/CLAUDE.md
ln -sf ~/docs-repo/claude-global/CLAUDE.md ~/.claude/CLAUDE.md

# Create system-issues directory and symlink files
mkdir -p ~/Documents/system-issues-fixes
cd ~/docs-repo/system-issues
for file in *.md; do
    ln -sf ~/docs-repo/system-issues/"$file" ~/Documents/system-issues-fixes/"$file"
done
```

---

## Notes

- **Hyprland config** (`~/.config/hypr/`) is also git-tracked separately
- This repo focuses on **documentation only**
- Actual config files remain in their original locations
- Symlinks ensure single source of truth

---

**Repository**: https://github.com/pranava-mk/arch-docs (configure remote)
