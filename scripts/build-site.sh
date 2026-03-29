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

# Publish novel cover assets into Astro's public directory using each book's route slug.
mkdir -p "$WEB_DIR/public/covers"
find "$WEB_DIR/public/covers" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.avif' \) \
    ! -name 'the-remnant-protocol-cover.png' \
    -delete

while IFS= read -r idea_file; do
    novel_dir="$(dirname "$idea_file")"
    route_slug="$(awk '/^slug:/{sub(/^slug:[[:space:]]*/, ""); print; exit}' "$idea_file")"

    [ -n "$route_slug" ] || continue

    cover_file=""
    for candidate in "$novel_dir"/cover.{png,jpg,jpeg,webp,avif} \
                     "$novel_dir"/Cover.{png,jpg,jpeg,webp,avif} \
                     "$novel_dir"/*cover*.{png,jpg,jpeg,webp,avif} \
                     "$novel_dir"/*Cover*.{png,jpg,jpeg,webp,avif} \
                     "$novel_dir"/*.{png,jpg,jpeg,webp,avif}; do
        [ -f "$candidate" ] || continue
        cover_file="$candidate"
        break
    done

    [ -n "$cover_file" ] || continue

    extension="${cover_file##*.}"
    cp "$cover_file" "$WEB_DIR/public/covers/$route_slug.$extension"
    log "[build-site] Published cover for $route_slug → /covers/$route_slug.$extension"
done < <(find "$NOVELS_DIR" -mindepth 2 -maxdepth 2 -name 'idea.md' | sort)

# Clear the previous static build so removed books/routes do not persist in dist.
rm -rf "$DIST_DIR"

npm run build

log "[build-site] Astro build complete → $DIST_DIR"
log "[build-site] Done: $BOOK_SLUG"
