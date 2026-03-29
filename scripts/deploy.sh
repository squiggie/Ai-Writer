#!/usr/bin/env bash
# =============================================================================
# deploy.sh — Push built site to gh-pages branch via git worktree
#
# Usage: deploy.sh <book_slug>
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

BOOK_SLUG="${1:?Usage: deploy.sh <book_slug>}"

[ -d "$DIST_DIR" ] || fail "Astro dist/ not found at $DIST_DIR — run build-site.sh first"

log "[deploy] Deploying: $BOOK_SLUG"

# ── Verify git is configured ───────────────────────────────────────────────
cd "$AIWRITER_DIR"
git rev-parse --git-dir >/dev/null 2>&1 || fail "Not a git repo. Run setup.sh first."

# ── Ensure source branch is clean and up to date ──────────────────────────
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ -n "$(git status --porcelain)" ]; then
    log "[deploy] Committing generated files on $CURRENT_BRANCH..."
    git add -A
    git commit -m "Add novel: $BOOK_SLUG [$(date '+%Y-%m-%d %H:%M')]"
fi

# ── Ensure gh-pages branch exists ─────────────────────────────────────────
if ! git ls-remote --exit-code --heads origin "$PAGES_BRANCH" >/dev/null 2>&1; then
    log "[deploy] Creating $PAGES_BRANCH branch..."
    git checkout --orphan "$PAGES_BRANCH"
    git reset --hard
    git commit --allow-empty -m "Initialize gh-pages"
    git push origin "$PAGES_BRANCH"
    git checkout "$SOURCE_BRANCH"
fi

# Sync the local publish branch to the latest remote tip before creating
# the worktree so pushes stay fast-forward even after remote-only updates.
git fetch origin "$PAGES_BRANCH" >/dev/null 2>&1 || true
if git show-ref --verify --quiet "refs/remotes/origin/$PAGES_BRANCH"; then
    git branch -f "$PAGES_BRANCH" "origin/$PAGES_BRANCH" >/dev/null 2>&1 || \
        git checkout -B "$PAGES_BRANCH" "origin/$PAGES_BRANCH" >/dev/null 2>&1
    git checkout "$CURRENT_BRANCH" >/dev/null 2>&1
fi

# ── Set up worktree for gh-pages ──────────────────────────────────────────
WORKTREE_DIR=$(mktemp -d)
log "[deploy] Worktree: $WORKTREE_DIR"

cleanup() {
    log "[deploy] Cleaning up worktree..."
    git worktree remove --force "$WORKTREE_DIR" 2>/dev/null || true
    rm -rf "$WORKTREE_DIR"
}
trap cleanup EXIT

git worktree add "$WORKTREE_DIR" "$PAGES_BRANCH"

# ── Copy Astro dist into worktree ─────────────────────────────────────────
log "[deploy] Copying Astro dist output..."

# Clear previous build from worktree (keep .git)
find "$WORKTREE_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

# Copy full Astro output
cp -r "$DIST_DIR/." "$WORKTREE_DIR/"

# Ensure .nojekyll so GitHub Pages serves files starting with underscore
touch "$WORKTREE_DIR/.nojekyll"

# ── Commit and push from worktree ─────────────────────────────────────────
cd "$WORKTREE_DIR"
git add -A

if git diff --cached --quiet; then
    log "[deploy] Nothing to commit — site already up to date"
else
    git commit -m "Publish: $BOOK_SLUG [$(date '+%Y-%m-%d %H:%M')]"
    log "[deploy] Pushing to origin/$PAGES_BRANCH..."
    git push origin "$PAGES_BRANCH"
    log "[deploy] Pushed successfully"
fi

log "[deploy] Live at: $GITHUB_PAGES_URL"
log "[deploy] Done: $BOOK_SLUG"
