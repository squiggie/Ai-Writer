#!/usr/bin/env bash
# =============================================================================
# setup.sh — One-time setup for the aiwriter pipeline
#
# Run once on a fresh server to install dependencies, configure git,
# initialize the site directory, and install the daily cron job.
#
# Usage: bash setup.sh
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

# ── Check required tools ───────────────────────────────────────────────────
require() {
    command -v "$1" >/dev/null 2>&1 && { log "  [ok] $1"; return 0; }
    log "  [missing] $1 — $2"
    return 1
}

log "======================================================"
log "aiwriter — Setup"
log "======================================================"

# ── 1. Verify core deps ───────────────────────────────────────────────────
log ""
log "[1/6] Checking dependencies..."

MISSING=0
require git    "install via system package manager" || MISSING=1
require python3 "install via system package manager" || MISSING=1
require codex  "install: npm install -g @openai/codex" || MISSING=1

# Install mdbook if not present
if ! require mdbook "installing now..."; then
    log "  Installing mdbook via cargo..."
    if command -v cargo >/dev/null 2>&1; then
        cargo install mdbook
    else
        # Fallback: download prebuilt binary
        MDBOOK_VERSION="v0.4.40"
        MDBOOK_URL="https://github.com/rust-lang/mdBook/releases/download/${MDBOOK_VERSION}/mdbook-${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
        TMP=$(mktemp -d)
        curl -sSL "$MDBOOK_URL" | tar -xz -C "$TMP"
        mkdir -p "$HOME/.local/bin"
        mv "$TMP/mdbook" "$HOME/.local/bin/"
        rm -rf "$TMP"
        export PATH="$HOME/.local/bin:$PATH"
        log "  mdbook installed to ~/.local/bin/"
        log "  Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

if [ "$MISSING" -eq 1 ]; then
    fail "One or more required tools are missing. Install them and re-run setup.sh."
fi

# ── 2. Create directory structure ─────────────────────────────────────────
log ""
log "[2/6] Creating directory structure..."

mkdir -p \
    "$NOVELS_DIR" \
    "$SITE_DIR/books" \
    "$SCRIPTS_DIR" \
    "$LOG_DIR"

log "  Created: $NOVELS_DIR"
log "  Created: $SITE_DIR"
log "  Created: $LOG_DIR"

# ── 3. Initialize library.json if not present ─────────────────────────────
LIBRARY_JSON="$SITE_DIR/library.json"
if [ ! -f "$LIBRARY_JSON" ]; then
    cat > "$LIBRARY_JSON" <<'JSON'
{
  "books": [],
  "last_updated": "",
  "total_books": 0
}
JSON
    log "  Initialized: $LIBRARY_JSON"
else
    log "  Exists: $LIBRARY_JSON"
fi

# ── 4. Initialize git repository ──────────────────────────────────────────
log ""
log "[4/6] Setting up git..."

cd "$AIWRITER_DIR"
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    git init
    log "  Initialized git repo at $AIWRITER_DIR"
else
    log "  Git repo already exists"
fi

# Create .gitignore
cat > "$AIWRITER_DIR/.gitignore" <<'GITIGNORE'
/var/log/
*.log
*.tmp
__pycache__/
*.py[cod]
GITIGNORE

# Check if remote is configured
if git remote get-url origin >/dev/null 2>&1; then
    log "  Remote 'origin' already configured: $(git remote get-url origin)"
else
    if [ "$GITHUB_REPO" = "git@github.com:YOUR_USERNAME/YOUR_REPO.git" ]; then
        warn "  GITHUB_REPO is still a placeholder."
        warn "  Edit scripts/config.sh and set GITHUB_REPO and GITHUB_PAGES_URL."
        warn "  Then re-run: git remote add origin <your-repo>"
    else
        git remote add origin "$GITHUB_REPO"
        log "  Remote 'origin' added: $GITHUB_REPO"
    fi
fi

# Initial commit if nothing has been committed yet
if ! git rev-parse HEAD >/dev/null 2>&1; then
    git add -A
    git commit -m "Initial aiwriter project setup"
    log "  Initial commit created"
fi

# Ensure source branch is named correctly
git checkout -B "$SOURCE_BRANCH" 2>/dev/null || true

# ── 5. Make scripts executable ────────────────────────────────────────────
log ""
log "[5/6] Setting script permissions..."

chmod +x "$SCRIPTS_DIR"/*.sh
log "  All .sh scripts marked executable"

# ── 6. Install daily cron job ─────────────────────────────────────────────
log ""
log "[6/6] Installing cron job..."

CRON_CMD="0 0 * * * $SCRIPTS_DIR/generate-book.sh >> $LOG_DIR/cron.log 2>&1"
CRON_MARKER="# aiwriter-daily"

# Check if already installed
if crontab -l 2>/dev/null | grep -q "aiwriter-daily"; then
    log "  Cron job already installed"
else
    (crontab -l 2>/dev/null || true; echo "$CRON_MARKER"; echo "$CRON_CMD") | crontab -
    log "  Cron job installed: runs daily at midnight"
    log "  Entry: $CRON_CMD"
fi

# ── Summary ───────────────────────────────────────────────────────────────
log ""
log "======================================================"
log "Setup complete"
log "======================================================"
log ""
log "Next steps:"
log "  1. Edit scripts/config.sh:"
log "       GITHUB_REPO      = your repo SSH URL"
log "       GITHUB_PAGES_URL = your GitHub Pages URL"
log "  2. Authenticate codex: codex auth"
log "  3. Push to GitHub:     git push -u origin $SOURCE_BRANCH"
log "  4. Test run:           bash $SCRIPTS_DIR/generate-book.sh"
log ""
log "Logs:    $LOG_DIR/"
log "Novels:  $NOVELS_DIR/"
log "Site:    $SITE_DIR/"
log ""
