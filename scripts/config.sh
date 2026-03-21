#!/usr/bin/env bash
# =============================================================================
# config.sh — Central configuration for the aiwriter pipeline
# Source this file at the top of every other script: source "$(dirname "$0")/config.sh"
# =============================================================================

# ── Paths ─────────────────────────────────────────────────────────────────────
AIWRITER_DIR="/storage/backup/landen/source/aiwriter"
NOVELS_DIR="$AIWRITER_DIR/novels"
SCRIPTS_DIR="$AIWRITER_DIR/scripts"
WEB_DIR="$AIWRITER_DIR/web"
DIST_DIR="$WEB_DIR/dist"
LOG_DIR="$AIWRITER_DIR/logs"
STATE_DIR="$AIWRITER_DIR/state"
ACTIVE_BOOK_FILE="$STATE_DIR/active-book.env"

# ── GitHub ────────────────────────────────────────────────────────────────────
# Set these before running setup.sh
GITHUB_REPO="git@github.com:squiggie/Ai-Writer.git"
GITHUB_PAGES_URL="https://squiggie.github.io/Ai-Writer"
SOURCE_BRANCH="main"
PAGES_BRANCH="gh-pages"

# ── Codex CLI ─────────────────────────────────────────────────────────────────
CODEX_SLEEP=20                   # Seconds between API calls (rate limit buffer)
CODEX_FAST_SLEEP=5               # Shorter sleep for quick metadata calls

# ── Book settings ─────────────────────────────────────────────────────────────
CHAPTERS_MIN=18          # Architect picks chapter count within this range
CHAPTERS_MAX=30
CHAPTERS_PER_RUN=4       # Default nightly batch size; set to 0 to write all remaining chapters
WORDS_MIN=2400           # Writer targets word count within this range per chapter
WORDS_MAX=3800
SITE_TITLE="The Daily Novel"
AUTO_START_NEXT_BOOK=0   # Nightly automation stops after the active book completes

# ── Shared logging ────────────────────────────────────────────────────────────
log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*"; }
warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]  $*"; }
fail() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; exit 1; }

ensure_state_dir() {
    mkdir -p "$STATE_DIR"
}

# ── Codex wrapper ─────────────────────────────────────────────────────────────
# Usage: run_codex WORKING_DIR "prompt" [sleep_seconds]
run_codex() {
    local dir="$1"
    local prompt="$2"
    local sleep_time="${3:-$CODEX_SLEEP}"

    codex exec \
        --dangerously-bypass-approvals-and-sandbox \
        -C "$dir" \
        "$prompt"

    sleep "$sleep_time"
}

# ── Outline helpers ───────────────────────────────────────────────────────────
chapter_count_from_outline() {
    local outline_file="$1"
    local fallback="${2:-$CHAPTERS_MAX}"
    local count

    count=$(grep -i "^Chapter count:" "$outline_file" 2>/dev/null | head -1 | grep -o '[0-9]*' || true)

    if [ -z "$count" ]; then
        count=$(grep -c '^### Chapter [0-9][0-9]*:' "$outline_file" 2>/dev/null || true)
    fi

    if [ -z "$count" ] || [ "$count" -eq 0 ] 2>/dev/null; then
        echo "$fallback"
        return
    fi

    echo "$count"
}

chapter_title_from_outline() {
    local outline_file="$1"
    local chapter_num="$2"

    awk -v chapter_num="$chapter_num" '
        index($0, "### Chapter " chapter_num ": ") == 1 {
            sub("^### Chapter " chapter_num ": ", "", $0)
            print
            exit
        }
    ' "$outline_file"
}

final_chapter_count() {
    local novel_dir="$1"
    local count=0
    local chapter_file

    for chapter_file in "$novel_dir"/chapters/chapter-[0-9][0-9].md; do
        [ -f "$chapter_file" ] || continue
        if grep -q "status: FINAL" "$chapter_file" 2>/dev/null; then
            count=$((count + 1))
        fi
    done

    echo "$count"
}

book_is_complete() {
    local novel_dir="$1"
    local chapter_total
    local chapter_final

    chapter_total=$(chapter_count_from_outline "$novel_dir/outline.md" "$CHAPTERS_MAX")
    chapter_final=$(final_chapter_count "$novel_dir")

    [ "$chapter_total" -gt 0 ] 2>/dev/null && [ "$chapter_final" -ge "$chapter_total" ]
}

get_active_book_slug() {
    if [ ! -f "$ACTIVE_BOOK_FILE" ]; then
        return 1
    fi

    sed -n 's/^ACTIVE_BOOK_SLUG=//p' "$ACTIVE_BOOK_FILE" | tail -1
}

set_active_book_slug() {
    local slug="$1"

    ensure_state_dir
    cat > "$ACTIVE_BOOK_FILE" <<EOF
ACTIVE_BOOK_SLUG=$slug
UPDATED_AT=$(date '+%Y-%m-%dT%H:%M:%SZ')
EOF
}

clear_active_book_slug() {
    rm -f "$ACTIVE_BOOK_FILE"
}

infer_incomplete_books() {
    local dir
    local slug

    for dir in "$NOVELS_DIR"/*; do
        [ -d "$dir" ] || continue
        [ -f "$dir/outline.md" ] || continue

        slug=$(basename "$dir")
        if ! book_is_complete "$dir" || [ ! -f "$dir/qa/final-review.md" ]; then
            echo "$slug"
        fi
    done
}

infer_unique_incomplete_book_slug() {
    local slug
    local inferred=""
    local count=0

    while IFS= read -r slug; do
        [ -n "$slug" ] || continue
        inferred="$slug"
        count=$((count + 1))
    done <<EOF
$(infer_incomplete_books)
EOF

    if [ "$count" -eq 1 ]; then
        echo "$inferred"
        return 0
    fi

    if [ "$count" -gt 1 ]; then
        warn "Multiple unfinished books found; set one active explicitly with scripts/activate-book.sh"
    fi

    return 1
}

get_or_infer_active_book_slug() {
    local slug

    slug=$(get_active_book_slug 2>/dev/null || true)
    if [ -n "$slug" ]; then
        echo "$slug"
        return 0
    fi

    slug=$(infer_unique_incomplete_book_slug || true)
    if [ -n "$slug" ]; then
        set_active_book_slug "$slug"
        echo "$slug"
        return 0
    fi

    return 1
}

final_review_status() {
    local novel_dir="$1"
    local review_file="$novel_dir/qa/final-review.md"

    if [ ! -f "$review_file" ]; then
        return 1
    fi

    sed -n 's/^status: //p' "$review_file" | head -1
}

# ── Guard: abort if required tools not found ──────────────────────────────────
check_deps() {
    command -v codex  >/dev/null 2>&1 || fail "codex not found. Run setup.sh first."
    command -v node   >/dev/null 2>&1 || fail "node not found. Install Node.js 18+ and re-run setup.sh."
    command -v npm    >/dev/null 2>&1 || fail "npm not found. Install Node.js 18+ and re-run setup.sh."
    command -v git    >/dev/null 2>&1 || fail "git not found."
}
