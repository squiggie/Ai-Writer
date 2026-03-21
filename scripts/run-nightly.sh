#!/usr/bin/env bash
# =============================================================================
# run-nightly.sh — Resume the single active book and stop when it is complete
#
# Usage: run-nightly.sh [--chapters-per-run N] [--dry-run]
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"
check_deps

usage() {
    cat <<EOF
Usage: $(basename "$0") [--chapters-per-run N] [--dry-run]
EOF
}

CHAPTERS_PER_RUN_LIMIT="$CHAPTERS_PER_RUN"
DRY_RUN=0

while [ "$#" -gt 0 ]; do
    case "$1" in
        --chapters-per-run)
            shift
            [ "$#" -gt 0 ] || fail "Missing value for --chapters-per-run"
            CHAPTERS_PER_RUN_LIMIT="$1"
            ;;
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
            fail "Unexpected argument: $1"
            ;;
    esac
    shift
done

case "$CHAPTERS_PER_RUN_LIMIT" in
    ''|*[!0-9]*)
        fail "chapters-per-run must be a non-negative integer"
        ;;
esac

if [ "$DRY_RUN" -eq 1 ]; then
    BOOK_SLUG=$(get_active_book_slug 2>/dev/null || true)
    if [ -z "$BOOK_SLUG" ]; then
        BOOK_SLUG=$(infer_unique_incomplete_book_slug || true)
    fi
else
    BOOK_SLUG=$(get_or_infer_active_book_slug || true)
fi

if [ -z "$BOOK_SLUG" ]; then
    log "[run-nightly] No active book. AUTO_START_NEXT_BOOK=$AUTO_START_NEXT_BOOK, exiting."
    exit 0
fi

NOVEL_DIR="$NOVELS_DIR/$BOOK_SLUG"
REVIEW_STATUS=""
if [ -d "$NOVEL_DIR" ]; then
    REVIEW_STATUS=$(final_review_status "$NOVEL_DIR" || true)
fi

if [ -d "$NOVEL_DIR" ] && book_is_complete "$NOVEL_DIR"; then
    if [ "$REVIEW_STATUS" = "PASS" ]; then
        log "[run-nightly] $BOOK_SLUG is already complete. Clearing active book and exiting."
        clear_active_book_slug
        exit 0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        log "[run-nightly] Dry run: would finalize completed book $BOOK_SLUG"
        exit 0
    fi

    if bash "$SCRIPTS_DIR/finalize-book.sh" "$BOOK_SLUG"; then
        clear_active_book_slug
        log "[run-nightly] Finalized $BOOK_SLUG and cleared active book"
        exit 0
    fi

    warn "[run-nightly] Finalization did not pass for $BOOK_SLUG; leaving it active"
    exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
    if [ -d "$NOVEL_DIR" ]; then
        log "[run-nightly] Dry run: would resume $BOOK_SLUG for up to $CHAPTERS_PER_RUN_LIMIT chapter(s)"
    else
        log "[run-nightly] Dry run: would start active book $BOOK_SLUG and write up to $CHAPTERS_PER_RUN_LIMIT chapter(s)"
    fi
    exit 0
fi

log "[run-nightly] Running active book: $BOOK_SLUG"
bash "$SCRIPTS_DIR/generate-book.sh" "$BOOK_SLUG" --chapters-per-run "$CHAPTERS_PER_RUN_LIMIT"

if [ -d "$NOVEL_DIR" ] && book_is_complete "$NOVEL_DIR"; then
    if bash "$SCRIPTS_DIR/finalize-book.sh" "$BOOK_SLUG"; then
        clear_active_book_slug
        log "[run-nightly] Finalized $BOOK_SLUG and cleared active book"
        exit 0
    fi

    warn "[run-nightly] Finalization did not pass for $BOOK_SLUG; leaving it active"
    exit 1
fi

log "[run-nightly] $BOOK_SLUG remains active for the next scheduled run"
