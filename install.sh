#!/usr/bin/env bash
# install.sh — Bootstrap restore script for archyde-prefs dotfiles
#
# Steps:
#   1. Safety guards (user, OS, cwd)
#   2. Install native pacman packages
#   3. Install paru (if absent) + AUR packages
#   4. HyDE confirmation gate
#   5. Stow all packages (with conflict backup)
#   6. Enable systemd units (system + user)
#   7. Rebuild font cache
#   8. Summary
#
# Usage:
#   ./install.sh                   # interactive
#   ./install.sh --skip-hyde-check # skip HyDE confirmation (CI / scripted)
#   NONINTERACTIVE=1 ./install.sh  # same as --skip-hyde-check

set -u  # treat unset variables as errors; NOT set -e (handled per-step)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'  # no colour

info()  { printf "${CYAN}[INFO]${NC}  %s\n" "$*"; }
ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
die()   { error "$*"; exit 1; }

SKIP_HYDE_CHECK=0
for arg in "$@"; do
    case "$arg" in
        --skip-hyde-check) SKIP_HYDE_CHECK=1 ;;
    esac
done
# Also honour env var for non-interactive callers
if [[ "${NONINTERACTIVE:-0}" == "1" ]]; then
    SKIP_HYDE_CHECK=1
fi

BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ---------------------------------------------------------------------------
# Step 1: Safety guards
# ---------------------------------------------------------------------------

info "Step 1/8 — Checking environment..."

# Must not run as root
if [[ "$(id -u)" -eq 0 ]]; then
    die "Do not run this script as root. Run as your normal user (sudo will be called internally where needed)."
fi

# Must be on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    die "This script is for Arch Linux only (/etc/arch-release not found)."
fi

# Must run from the repo root (install.sh must live alongside packages/)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$REPO_ROOT/packages/pacman-native.txt" ]] || \
   [[ ! -f "$REPO_ROOT/packages/pacman-aur.txt" ]]; then
    die "Run this script from the archyde-prefs repo root (packages/ not found at $REPO_ROOT)."
fi

ok "Running as $(id -un) on Arch Linux from $REPO_ROOT."

# ---------------------------------------------------------------------------
# Step 2: Native pacman packages
# ---------------------------------------------------------------------------

info "Step 2/8 — Installing native pacman packages..."

if sudo pacman -S --needed - < "$REPO_ROOT/packages/pacman-native.txt"; then
    ok "Native packages installed."
else
    die "pacman returned a non-zero exit code. Fix errors above and re-run."
fi

# ---------------------------------------------------------------------------
# Step 3: paru + AUR packages
# ---------------------------------------------------------------------------

info "Step 3/8 — Installing AUR packages via paru..."

if ! command -v paru &>/dev/null; then
    info "paru not found — building from AUR..."
    PARU_TMP="$(mktemp -d)"
    # Use trap to clean up the temp dir on exit
    trap 'rm -rf "$PARU_TMP"' EXIT

    if git clone https://aur.archlinux.org/paru-bin.git "$PARU_TMP/paru-bin"; then
        pushd "$PARU_TMP/paru-bin" >/dev/null
        if makepkg -si --noconfirm; then
            popd >/dev/null
            ok "paru installed."
        else
            popd >/dev/null
            die "makepkg failed. Install paru manually and re-run."
        fi
    else
        die "Failed to clone paru-bin from AUR. Check network connectivity."
    fi
else
    ok "paru already installed: $(command -v paru)"
fi

if paru -S --needed - < "$REPO_ROOT/packages/pacman-aur.txt"; then
    ok "AUR packages installed."
else
    die "paru returned a non-zero exit code. Fix errors above and re-run."
fi

# ---------------------------------------------------------------------------
# Step 4: HyDE confirmation gate
# ---------------------------------------------------------------------------

info "Step 4/8 — HyDE installation check..."

cat <<'HYDE_NOTICE'

  ┌─────────────────────────────────────────────────────────────────────────┐
  │                     MANUAL STEP REQUIRED: HyDE                         │
  │                                                                         │
  │  HyDE (Hyprland Desktop Environment) MUST be installed BEFORE stowing  │
  │  dotfiles. HyDE lays down base configs under ~/.config/ that this       │
  │  repo's stow packages override with user-specific deltas.              │
  │                                                                         │
  │  If you stow before HyDE installs, HyDE will refuse to overwrite the   │
  │  symlinks and your install will be broken or incomplete.               │
  │                                                                         │
  │  Install HyDE first:                                                    │
  │    https://github.com/prasanthrangan/hyprdots                          │
  │                                                                         │
  │  After HyDE is installed, re-run this script (or continue below).      │
  └─────────────────────────────────────────────────────────────────────────┘

HYDE_NOTICE

if [[ "$SKIP_HYDE_CHECK" -eq 1 ]]; then
    warn "Skipping HyDE confirmation (--skip-hyde-check / NONINTERACTIVE=1 set)."
else
    printf "Is HyDE already installed? [y/N] "
    read -r hyde_answer
    case "$hyde_answer" in
        [yY]|[yY][eE][sS])
            ok "HyDE confirmed — continuing to stow."
            ;;
        *)
            info "Aborting. Install HyDE first, then re-run: ./install.sh"
            exit 0
            ;;
    esac
fi

# ---------------------------------------------------------------------------
# Step 5: Stow packages
# ---------------------------------------------------------------------------

info "Step 5/8 — Stowing dotfile packages..."

STOW_PACKAGES=(
    hyprland
    kitty
    wireplumber
    fontconfig
    claude-global
    archyde-issues-fixes
    shell
    apps
    bin
)

# backup_and_stow <package>
# Runs stow --no (dry-run) to detect conflicts, backs up conflicting files,
# then runs the real stow. Never uses --adopt (which would overwrite repo files).
backup_and_stow() {
    local pkg="$1"
    local pkg_dir="$REPO_ROOT/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        warn "Package directory not found, skipping: $pkg_dir"
        return 0
    fi

    # Dry-run: capture any conflict messages
    local dry_output
    dry_output="$(stow --no --target "$HOME" --dir "$REPO_ROOT" "$pkg" 2>&1)" || true

    # stow prints "CONFLICT: ..." lines for files that block it
    local conflicts
    conflicts="$(printf '%s\n' "$dry_output" | grep -i 'CONFLICT\|existing target' || true)"

    if [[ -n "$conflicts" ]]; then
        warn "Conflicts detected for package '$pkg' — backing up conflicting files..."

        # Parse conflicting target paths from stow output.
        # stow --no lines look like:
        #   CONFLICT: <pkg>/<rel-path> vs. <target-path>   (stow 2.x)
        # Extract the live file path (after "vs.")
        while IFS= read -r line; do
            local live_path
            # Try to extract path after "existing target is"
            live_path="$(printf '%s' "$line" | grep -oP '(?<=(existing target is|vs\.) ).*' || true)"
            if [[ -z "$live_path" ]]; then
                # Fallback: last token
                live_path="${line##* }"
            fi

            # Expand ~ if present
            live_path="${live_path/#\~/$HOME}"

            if [[ -e "$live_path" ]] || [[ -L "$live_path" ]]; then
                local rel_path="${live_path#"$HOME/"}"
                local backup_target="$BACKUP_DIR/$rel_path"
                mkdir -p "$(dirname "$backup_target")"
                info "Backing up: $live_path -> $backup_target"
                mv "$live_path" "$backup_target"
            fi
        done <<< "$conflicts"
    fi

    # Real stow
    if stow --target "$HOME" --dir "$REPO_ROOT" "$pkg"; then
        ok "Stowed: $pkg"
    else
        warn "stow failed for '$pkg'. Check output above. Continuing with remaining packages."
    fi
}

stow_errors=0
for pkg in "${STOW_PACKAGES[@]}"; do
    backup_and_stow "$pkg" || stow_errors=$((stow_errors + 1))
done

if [[ "$stow_errors" -gt 0 ]]; then
    warn "$stow_errors package(s) had stow errors. Review output above."
else
    ok "All packages stowed successfully."
fi

# ---------------------------------------------------------------------------
# Step 6: Enable systemd units
# ---------------------------------------------------------------------------

info "Step 6/8 — Enabling systemd units..."

# System units
system_errors=0
while IFS= read -r unit || [[ -n "$unit" ]]; do
    # Skip blank lines and comments
    [[ -z "$unit" || "$unit" == \#* ]] && continue

    # Skip template units (e.g. getty@.service) — they require an instance name
    if [[ "$unit" == *'@.'* ]]; then
        info "Skipping template unit (instance-specific): $unit"
        continue
    fi

    if sudo systemctl enable "$unit" 2>/dev/null; then
        ok "System unit enabled: $unit"
    else
        warn "Could not enable system unit '$unit' (package may not be installed — this is non-fatal)."
        system_errors=$((system_errors + 1))
    fi
done < "$REPO_ROOT/packages/systemd-system-enabled.txt"

# User units
user_errors=0
while IFS= read -r unit || [[ -n "$unit" ]]; do
    [[ -z "$unit" || "$unit" == \#* ]] && continue

    if [[ "$unit" == *'@.'* ]]; then
        info "Skipping template unit (instance-specific): $unit"
        continue
    fi

    if systemctl --user enable "$unit" 2>/dev/null; then
        ok "User unit enabled: $unit"
    else
        warn "Could not enable user unit '$unit' (package may not be installed — this is non-fatal)."
        user_errors=$((user_errors + 1))
    fi
done < "$REPO_ROOT/packages/systemd-user-enabled.txt"

if [[ $((system_errors + user_errors)) -gt 0 ]]; then
    warn "$((system_errors + user_errors)) unit(s) could not be enabled (expected for machine-specific units like proton.VPN.service, tailscaled.service)."
fi

# ---------------------------------------------------------------------------
# Step 7: Font cache
# ---------------------------------------------------------------------------

info "Step 7/8 — Rebuilding font cache..."

if fc-cache -fv; then
    ok "Font cache rebuilt."
else
    warn "fc-cache returned non-zero. Fonts may not be fully available until next login."
fi

# ---------------------------------------------------------------------------
# Step 8: Summary
# ---------------------------------------------------------------------------

info "Step 8/8 — Done."

printf '\n'
printf "${BOLD}${GREEN}Bootstrap complete.${NC}\n"
printf '\n'
printf "  Packages stowed : %s\n" "${STOW_PACKAGES[*]}"
if [[ -d "$BACKUP_DIR" ]]; then
    printf "  Backups saved   : %s\n" "$BACKUP_DIR"
fi
printf '\n'
printf "Next steps:\n"
printf "  1. Log out and back in (or reboot) so user systemd units and PATH changes take effect.\n"
printf "  2. If wallpaper is missing on DP-1: ~/.local/lib/hyde/wallpaper.sh --start --backend swww --global\n"
printf "  3. Restart Waybar if needed: systemctl --user restart hyde-Hyprland-bar.service\n"
printf '\n'
