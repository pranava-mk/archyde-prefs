# Documentation Repository Setup Guide

Quick reference for managing the documentation repository.

---

## Current Setup

✅ **Repository**: `~/docs-repo/`
✅ **Git initialized**: Yes
✅ **Symlinks created**: Yes

### Symlinks Active

```bash
~/.config/hypr/CLAUDE.md → ~/docs-repo/hyprland/CLAUDE.md
~/.claude/CLAUDE.md → ~/docs-repo/claude-global/CLAUDE.md
~/Documents/system-issues-fixes/*.md → ~/docs-repo/system-issues/*.md
```

---

## Daily Workflow

### 1. Edit Documentation

Just edit files in their normal locations (symlinks handle the rest):

```bash
# Edit Hyprland docs
micro ~/.config/hypr/CLAUDE.md

# Edit global Claude config
micro ~/.claude/CLAUDE.md

# Add new system issue
micro ~/Documents/system-issues-fixes/2026-02-XX_issue-name.md
```

### 2. Check What Changed

```bash
cd ~/docs-repo
git status
git diff
```

### 3. Commit Changes

```bash
cd ~/docs-repo
git add -A
git commit -m "Descriptive commit message"
```

### 4. Push to Remote (after setup)

```bash
cd ~/docs-repo
git push
```

---

## One-Time Remote Setup

### Option A: GitHub (Recommended)

1. **Create GitHub repository**:
   - Go to https://github.com/new
   - Repository name: `arch-docs` (or `system-docs`)
   - Make it **private** (contains system-specific info)
   - Don't initialize with README (already have one)

2. **Add remote and push**:
   ```bash
   cd ~/docs-repo
   git remote add origin git@github.com:pranava-mk/arch-docs.git
   git branch -M main
   git push -u origin main
   ```

3. **Future pushes**:
   ```bash
   cd ~/docs-repo
   git push
   ```

### Option B: GitLab

```bash
cd ~/docs-repo
git remote add origin git@gitlab.com:pranava-mk/arch-docs.git
git branch -M main
git push -u origin main
```

### Option C: Self-hosted Git Server

```bash
cd ~/docs-repo
git remote add origin user@server:~/arch-docs.git
git branch -M main
git push -u origin main
```

---

## Restoring on New Machine

### 1. Clone Repository

```bash
git clone git@github.com:pranava-mk/arch-docs.git ~/docs-repo
```

### 2. Create Symlinks

```bash
# Hyprland CLAUDE.md
ln -sf ~/docs-repo/hyprland/CLAUDE.md ~/.config/hypr/CLAUDE.md

# Global CLAUDE.md
ln -sf ~/docs-repo/claude-global/CLAUDE.md ~/.claude/CLAUDE.md

# System issues (all .md files)
mkdir -p ~/Documents/system-issues-fixes
cd ~/docs-repo/system-issues
for file in *.md; do
    ln -sf ~/docs-repo/system-issues/"$file" ~/Documents/system-issues-fixes/"$file"
done
```

### 3. Verify Symlinks

```bash
ls -la ~/.config/hypr/CLAUDE.md
ls -la ~/.claude/CLAUDE.md
ls -la ~/Documents/system-issues-fixes/
```

---

## Adding New Documentation

### New System Issue

```bash
# Create new issue file (will auto-symlink if in ~/Documents/system-issues-fixes/)
micro ~/Documents/system-issues-fixes/2026-02-XX_new-issue.md

# If created directly in repo, create symlink
cd ~/Documents/system-issues-fixes
ln -s ~/docs-repo/system-issues/2026-02-XX_new-issue.md .

# Commit
cd ~/docs-repo
git add system-issues/2026-02-XX_new-issue.md
git commit -m "Add: New issue documentation"
git push
```

### New Documentation Category

```bash
# Create new directory
mkdir ~/docs-repo/new-category

# Add files
micro ~/docs-repo/new-category/README.md

# Create symlink if needed
ln -s ~/docs-repo/new-category ~/somewhere/new-category

# Commit
cd ~/docs-repo
git add new-category/
git commit -m "Add: New documentation category"
git push
```

---

## Useful Git Commands

### Check Status

```bash
cd ~/docs-repo
git status          # See what changed
git diff            # See detailed changes
git log --oneline   # View commit history
```

### Undo Changes

```bash
# Discard changes to a file (before staging)
git restore system-issues/some-file.md

# Unstage a file
git restore --staged system-issues/some-file.md

# Undo last commit (keep changes)
git reset --soft HEAD~1
```

### View History

```bash
# View all commits
git log

# View compact history
git log --oneline --graph

# View changes in a specific file
git log -p system-issues/some-file.md
```

---

## Backup Strategy

### Local Backup

```bash
# Create compressed backup
tar -czf ~/docs-repo-backup-$(date +%Y%m%d).tar.gz ~/docs-repo

# Or use rsync
rsync -av ~/docs-repo/ /path/to/backup/docs-repo/
```

### Remote Backup

Git remote serves as automatic backup when you push regularly.

**Best practice**: Push after every significant change:
```bash
cd ~/docs-repo && git add -A && git commit -m "Update docs" && git push
```

---

## Troubleshooting

### Symlink Broken

```bash
# Check if symlink is valid
ls -la ~/.config/hypr/CLAUDE.md

# Recreate symlink
rm ~/.config/hypr/CLAUDE.md
ln -s ~/docs-repo/hyprland/CLAUDE.md ~/.config/hypr/CLAUDE.md
```

### Git Push Rejected

```bash
# Pull remote changes first
cd ~/docs-repo
git pull --rebase

# Then push
git push
```

### Merge Conflicts

```bash
# View conflicting files
git status

# Edit conflicting files manually
micro path/to/conflicting-file.md

# Mark as resolved and continue
git add path/to/conflicting-file.md
git rebase --continue
```

---

## Notes

- **Never edit files directly in `~/docs-repo/`** - always use symlinks
- **Commit regularly** - small, frequent commits are better
- **Write descriptive commit messages** - helps future you
- **Push often** - ensures remote backup is up-to-date

---

**Created**: 2026-02-13
**Author**: pranava-mk
