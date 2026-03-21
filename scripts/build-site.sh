#!/usr/bin/env bash
# =============================================================================
# build-site.sh — Build the Astro site
#
# Usage: build-site.sh <novel_dir> <book_slug>
#
# Builds the entire site from web/ — all novels are included in a single
# Astro build. Arguments are accepted for pipeline compatibility but the
# build always covers every novel.
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

NOVEL_DIR="${1:?Usage: build-site.sh <novel_dir> <book_slug>}"
BOOK_SLUG="${2:?Missing book slug}"

log "[build-site] Building Astro site (triggered by: $BOOK_SLUG)"

command -v node >/dev/null 2>&1 || fail "node not found. Run setup.sh first."
command -v npm  >/dev/null 2>&1 || fail "npm not found. Run setup.sh first."

cd "$WEB_DIR"

# Install dependencies if node_modules is missing
if [ ! -d "$WEB_DIR/node_modules" ]; then
    log "[build-site] node_modules not found — running npm install..."
    npm install
fi

npm run build

log "[build-site] Astro build complete → $DIST_DIR"
log "[build-site] Done: $BOOK_SLUG"
