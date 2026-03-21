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
require node   "install Node.js 18+ from https://nodejs.org or via nvm" || MISSING=1
require npm    "included with Node.js" || MISSING=1
require codex  "install: npm install -g @openai/codex" || MISSING=1

if [ "$MISSING" -eq 1 ]; then
    fail "One or more required tools are missing. Install them and re-run setup.sh."
fi

# ── 2. Create directory structure ─────────────────────────────────────────
log ""
log "[2/6] Creating directory structure..."

mkdir -p \
    "$NOVELS_DIR" \
    "$WEB_DIR" \
    "$SCRIPTS_DIR" \
    "$LOG_DIR" \
    "$STATE_DIR"

log "  Created: $NOVELS_DIR"
log "  Created: $WEB_DIR"
log "  Created: $LOG_DIR"
log "  Created: $STATE_DIR"

# ── 3. Install Astro dependencies ──────────────────────────────────────────
log ""
log "[3/6] Installing Astro dependencies..."

if [ -f "$WEB_DIR/package.json" ]; then
    cd "$WEB_DIR"
    npm install
    log "  npm install complete"
else
    log "  web/package.json not found — skipping npm install"
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
state/
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

CRON_CMD="0 0 * * * $SCRIPTS_DIR/run-nightly.sh --chapters-per-run $CHAPTERS_PER_RUN >> $LOG_DIR/cron.log 2>&1"
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
log "  4. Activate a book:    bash $SCRIPTS_DIR/activate-book.sh your-book-slug"
log "  5. Test nightly run:   bash $SCRIPTS_DIR/run-nightly.sh --dry-run"
log ""
log "Logs:    $LOG_DIR/"
log "Novels:  $NOVELS_DIR/"
log "Web:     $WEB_DIR/"
log "Dist:    $DIST_DIR/ (created on first build)"
log ""
