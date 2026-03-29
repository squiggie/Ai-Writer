#!/usr/bin/env bash
# =============================================================================
# finalize-book.sh — Run the final completion audit for a finished manuscript
#
# Usage: finalize-book.sh <book-slug> [--dry-run]
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"
check_deps

usage() {
    cat <<EOF
Usage: $(basename "$0") <book-slug> [--dry-run]
EOF
}

BOOK_SLUG=""
DRY_RUN=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            fail "Unknown option: $1"
            ;;
        *)
            if [ -n "$BOOK_SLUG" ]; then
                fail "Only one book slug may be provided"
            fi
            BOOK_SLUG="$1"
            ;;
    esac
    shift
done

[ -n "$BOOK_SLUG" ] || fail "Missing book slug"

NOVEL_DIR="$NOVELS_DIR/$BOOK_SLUG"
[ -d "$NOVEL_DIR" ] || fail "Novel directory not found: $NOVEL_DIR"
[ -f "$NOVEL_DIR/outline.md" ] || fail "outline.md not found in $NOVEL_DIR"

CHAPTER_TOTAL=$(chapter_count_from_outline "$NOVEL_DIR/outline.md" "$CHAPTERS_MAX")
CHAPTER_FINAL=$(final_chapter_count "$NOVEL_DIR")

if [ "$CHAPTER_FINAL" -lt "$CHAPTER_TOTAL" ]; then
    fail "Cannot finalize $BOOK_SLUG: only $CHAPTER_FINAL/$CHAPTER_TOTAL chapters are FINAL"
fi

mkdir -p "$NOVEL_DIR/qa"

if [ "$DRY_RUN" -eq 1 ]; then
    log "[finalize-book] Dry run for $BOOK_SLUG"
    log "[finalize-book] Chapters FINAL: $CHAPTER_FINAL/$CHAPTER_TOTAL"
    exit 0
fi

log "[finalize-book] Running final completion audit for $BOOK_SLUG"
run_codex "$NOVEL_DIR" \
    "Read outline.md, themes.md, memory.md, and every FINAL chapter file in chapters/chapter-XX.md.

You are performing the final unattended completion audit for this finished novel.

Tasks:
1. Verify the finished manuscript fulfills the outline's promised beats, resolves the central arc, and lands the ending with closure appropriate to the genre.
2. Update memory.md so the chapter progress log, character/world state, and revision history accurately reflect the completed manuscript.
3. If you find small or moderate blocking issues in continuity, payoff, escalation, or ending clarity, make targeted fixes directly in the affected FINAL chapter files and/or memory.md.
4. Do not rewrite healthy chapters wholesale. Preserve the existing voice, structure, and scene architecture unless a concrete blocker requires a focused correction.
5. Save qa/final-review.md with this exact frontmatter:
---
status: PASS or REVISE
chapters_total: $CHAPTER_TOTAL
chapters_final: $CHAPTER_FINAL
---

Then include these sections:
## Completion Audit
## Book-Level Fixes Applied
## Remaining Risks

Mark status PASS only if there are no blocking issues left after your edits. Mark REVISE only if a blocking issue remains unresolved.

Output nothing else."

REVIEW_STATUS=$(final_review_status "$NOVEL_DIR" || true)
if [ "$REVIEW_STATUS" != "PASS" ]; then
    warn "[finalize-book] Final review did not pass for $BOOK_SLUG"
    exit 1
fi

DATE=$(date +%Y-%m-%d)
log "[finalize-book] Final audit PASS — rebuilding and publishing"
bash "$SCRIPTS_DIR/build-site.sh" "$NOVEL_DIR" "$BOOK_SLUG"
bash "$SCRIPTS_DIR/deploy.sh" "$BOOK_SLUG"

log "[finalize-book] Complete: $BOOK_SLUG"
