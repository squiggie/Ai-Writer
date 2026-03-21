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

TITLE=$(grep -m1 "^title:" "$IDEA_FILE" | cut -d: -f2- | xargs)
GENRE=$(grep -m1 "^genre:" "$IDEA_FILE" | cut -d: -f2- | xargs)
[ -n "$TITLE" ] || TITLE="$BOOK_SLUG"

log "[build-site] Title: $TITLE"

# ── Create mdBook source directory ────────────────────────────────────────
MDSRC="$NOVEL_DIR/mdsrc"
mkdir -p "$MDSRC/chapters"

# ── Generate book.toml ────────────────────────────────────────────────────
cat > "$MDSRC/book.toml" <<TOML
[book]
title = "$(echo "$TITLE" | sed "s/\"/'/g")"
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

# ── Generate SUMMARY.md via Codex ─────────────────────────────────────────
log "[build-site] Generating SUMMARY.md..."
run_codex "$NOVEL_DIR" \
    "Read outline.md and the list of files in chapters/ directory.

Generate mdsrc/SUMMARY.md for mdBook with this exact format:

# Summary

[Introduction](README.md)

---

$(for i in $(seq 1 "$CHAPTERS_PER_BOOK"); do
    PADDED=$(printf '%02d' "$i")
    echo "- [Chapter $i: TITLE_FROM_OUTLINE](chapters/chapter-${PADDED}.md)"
done)

Rules:
- Read each chapter title from outline.md for Chapter 1 through $CHAPTERS_PER_BOOK
- Only include chapters that exist as chapter-XX.md files in mdsrc/chapters/ (already copied there)
- Use format: - [Chapter N: Title](chapters/chapter-NN.md)
- The README.md link must always be first
- Do not include draft, dev-review, or line-review files
- Save to mdsrc/SUMMARY.md. Output nothing else." \
    "$CODEX_FAST_SLEEP"

# ── Generate README.md (book intro page) ──────────────────────────────────
log "[build-site] Generating README.md..."
run_codex "$NOVEL_DIR" \
    "Read idea.md and style-guide.md.

Generate mdsrc/README.md — the introduction page for this novel's mdBook site.

Include:
- Novel title as H1
- Genre and comp authors (one line each)
- Premise paragraph (from idea.md)
- A brief 'About this novel' note (2-3 sentences on Christian worldview integration — specific to this book, not generic)
- No spoilers past Chapter 3

Save to mdsrc/README.md. Output nothing else." \
    "$CODEX_FAST_SLEEP"

# ── Build the mdBook site ──────────────────────────────────────────────────
log "[build-site] Running mdbook build..."
mdbook build "$MDSRC" --dest-dir "$BOOK_SITE_DIR"

log "[build-site] Built to: $BOOK_SITE_DIR"
log "[build-site] Done: $BOOK_SLUG"
