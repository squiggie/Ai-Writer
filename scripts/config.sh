#!/usr/bin/env bash
# =============================================================================
# config.sh — Central configuration for the aiwriter pipeline
# Source this file at the top of every other script: source "$(dirname "$0")/config.sh"
# =============================================================================

# ── Paths ─────────────────────────────────────────────────────────────────────
AIWRITER_DIR="/storage/backup/landen/source/aiwriter"
NOVELS_DIR="$AIWRITER_DIR/novels"
SCRIPTS_DIR="$AIWRITER_DIR/scripts"
SITE_DIR="$AIWRITER_DIR/site"
LOG_DIR="$AIWRITER_DIR/logs"

# ── GitHub ────────────────────────────────────────────────────────────────────
# Set these before running setup.sh
GITHUB_REPO="git@github.com:squiggie/Ai-Writer.git"
GITHUB_PAGES_URL="https://squiggie.github.io/Ai-Writer"
SOURCE_BRANCH="main"
PAGES_BRANCH="gh-pages"

# ── Codex CLI ─────────────────────────────────────────────────────────────────
CODEX_APPROVAL="never"           # Never ask for approval (required for automation)
CODEX_SANDBOX="workspace-write"  # Can write to working directory
CODEX_SLEEP=20                   # Seconds between API calls (rate limit buffer)
CODEX_FAST_SLEEP=5               # Shorter sleep for quick metadata calls

# ── Book settings ─────────────────────────────────────────────────────────────
CHAPTERS_PER_BOOK=23
SITE_TITLE="The Daily Novel"

# ── Shared logging ────────────────────────────────────────────────────────────
log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO]  $*"; }
warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN]  $*"; }
fail() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; exit 1; }

# ── Codex wrapper ─────────────────────────────────────────────────────────────
# Usage: run_codex WORKING_DIR "prompt" [sleep_seconds]
run_codex() {
    local dir="$1"
    local prompt="$2"
    local sleep_time="${3:-$CODEX_SLEEP}"

    codex exec \
        -a "$CODEX_APPROVAL" \
        -s "$CODEX_SANDBOX" \
        -C "$dir" \
        "$prompt"

    sleep "$sleep_time"
}

# ── Guard: abort if codex not found ───────────────────────────────────────────
check_deps() {
    command -v codex  >/dev/null 2>&1 || fail "codex not found. Run setup.sh first."
    command -v mdbook >/dev/null 2>&1 || fail "mdbook not found. Run setup.sh first."
    command -v python3 >/dev/null 2>&1 || fail "python3 not found."
    command -v git    >/dev/null 2>&1 || fail "git not found."
}
