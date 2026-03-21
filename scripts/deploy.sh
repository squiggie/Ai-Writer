#!/usr/bin/env bash
# =============================================================================
# deploy.sh — Push built site to gh-pages branch via git worktree
#
# Usage: deploy.sh <book_slug>
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

BOOK_SLUG="${1:?Usage: deploy.sh <book_slug>}"

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

# ── Copy built site files into worktree ───────────────────────────────────
log "[deploy] Copying site output..."

# Copy site index and library
cp -f "$SITE_DIR/index.html" "$WORKTREE_DIR/"
cp -f "$SITE_DIR/library.json" "$WORKTREE_DIR/"

# Copy this book's built HTML
BOOK_BUILD_SRC="$SITE_DIR/books/$BOOK_SLUG"
BOOK_BUILD_DST="$WORKTREE_DIR/books/$BOOK_SLUG"
[ -d "$BOOK_BUILD_SRC" ] || fail "Built book site not found at $BOOK_BUILD_SRC — run build-site.sh first"

mkdir -p "$WORKTREE_DIR/books"
rm -rf "$BOOK_BUILD_DST"
cp -r "$BOOK_BUILD_SRC" "$BOOK_BUILD_DST"

# Add .nojekyll so GitHub Pages serves files starting with underscore
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
