#!/usr/bin/env bash
# =============================================================================
# build-site.sh — Generate SUMMARY.md and build the mdBook site for one novel
#
# Usage: build-site.sh <novel_dir> <book_slug>
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

NOVEL_DIR="${1:?Usage: build-site.sh <novel_dir> <book_slug>}"
BOOK_SLUG="${2:?Missing book slug}"
BOOK_SITE_DIR="$SITE_DIR/books/$BOOK_SLUG"

log "[build-site] Building: $BOOK_SLUG"

# ── Verify mdBook is available ─────────────────────────────────────────────
command -v mdbook >/dev/null 2>&1 || fail "mdbook not found. Run setup.sh first."

# ── Pull title and metadata from idea.md ──────────────────────────────────
IDEA_FILE="$NOVEL_DIR/idea.md"
[ -f "$IDEA_FILE" ] || fail "idea.md not found at $IDEA_FILE"

BOOK_TITLE=$(grep -m1 "^title:" "$IDEA_FILE" | cut -d: -f2- | xargs)
GENRE=$(grep -m1 "^genre:" "$IDEA_FILE" | cut -d: -f2- | xargs)
COMP_AUTHORS=$(grep -m1 "^comp_authors:" "$IDEA_FILE" | cut -d: -f2- | xargs)
[ -n "$BOOK_TITLE" ] || BOOK_TITLE="$BOOK_SLUG"

log "[build-site] Title: $BOOK_TITLE"

# ── Create mdBook source directory ────────────────────────────────────────
MDSRC="$NOVEL_DIR/mdsrc"
mkdir -p "$MDSRC/chapters"

# ── Generate book.toml ────────────────────────────────────────────────────
cat > "$MDSRC/book.toml" <<TOML
[book]
title = "$(echo "$BOOK_TITLE" | sed "s/\"/'/g")"
authors = ["The Daily Novel"]
language = "en"
src = "."

[output.html]
site-url = "/$(basename "$SITE_DIR")/books/$BOOK_SLUG/"
git-repository-url = "$GITHUB_REPO"
edit-url-template = ""
no-section-label = true

[output.html.fold]
enable = false
TOML

# ── Copy chapter files ─────────────────────────────────────────────────────
CHAPTER_COUNT=0
for f in "$NOVEL_DIR/chapters"/chapter-[0-9][0-9].md; do
    [ -f "$f" ] || continue
    grep -q "status: FINAL" "$f" 2>/dev/null || { log "[build-site] Skipping non-FINAL: $(basename "$f")"; continue; }
    cp "$f" "$MDSRC/chapters/"
    CHAPTER_COUNT=$((CHAPTER_COUNT + 1))
done

log "[build-site] $CHAPTER_COUNT FINAL chapters copied"

CHAPTERS_PER_BOOK=$(chapter_count_from_outline "$NOVEL_DIR/outline.md" "$CHAPTERS_MAX")
if [ "$CHAPTERS_PER_BOOK" -lt "$CHAPTERS_MIN" ] || [ "$CHAPTERS_PER_BOOK" -gt "$CHAPTERS_MAX" ] 2>/dev/null; then
    log "[build-site] Chapter count $CHAPTERS_PER_BOOK out of range — defaulting to $CHAPTERS_MIN"
    CHAPTERS_PER_BOOK="$CHAPTERS_MIN"
fi

extract_section() {
    local heading="$1"

    awk -v heading="## $heading" '
        $0 == heading { capture = 1; next }
        /^## / && capture { exit }
        capture { print }
    ' "$IDEA_FILE"
}

# ── Generate SUMMARY.md locally ────────────────────────────────────────────
log "[build-site] Generating SUMMARY.md..."
{
    echo "# Summary"
    echo
    echo "[Introduction](README.md)"
    echo
    echo "---"
    echo

    for i in $(seq 1 "$CHAPTERS_PER_BOOK"); do
        PADDED=$(printf '%02d' "$i")
        if [ ! -f "$MDSRC/chapters/chapter-${PADDED}.md" ]; then
            continue
        fi

        CHAPTER_TITLE=$(chapter_title_from_outline "$NOVEL_DIR/outline.md" "$i")
        [ -n "$CHAPTER_TITLE" ] || CHAPTER_TITLE="Chapter $i"
        printf -- "- [Chapter %s: %s](chapters/chapter-%s.md)\n" "$i" "$CHAPTER_TITLE" "$PADDED"
    done
} > "$MDSRC/SUMMARY.md"

# ── Generate README.md locally ─────────────────────────────────────────────
log "[build-site] Generating README.md..."
PREMISE=$(extract_section "Premise")
WORLDVIEW=$(extract_section "Christian Worldview Integration")

{
    printf '# %s\n\n' "$BOOK_TITLE"
    printf '**Genre:** %s  \n' "$GENRE"
    if [ -n "$COMP_AUTHORS" ]; then
        printf '**In the tradition of:** %s\n' "$COMP_AUTHORS"
    fi
    echo
    echo "## Premise"
    if [ -n "$PREMISE" ]; then
        printf '%s\n' "$PREMISE"
    else
        echo "Premise coming soon."
    fi
    echo
    echo "## About this novel"
    if [ -n "$WORLDVIEW" ]; then
        printf '%s\n' "$WORLDVIEW"
    else
        echo "This story explores its worldview through character choices, consequence, grace, and redemption."
    fi
} > "$MDSRC/README.md"

# ── Build the mdBook site ──────────────────────────────────────────────────
log "[build-site] Running mdbook build..."
mdbook build "$MDSRC" --dest-dir "$BOOK_SITE_DIR"

log "[build-site] Built to: $BOOK_SITE_DIR"
log "[build-site] Done: $BOOK_SLUG"
