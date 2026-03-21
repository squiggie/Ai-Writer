#!/usr/bin/env bash
# =============================================================================
# activate-book.sh — Set or clear the single active book for nightly automation
#
# Usage:
#   activate-book.sh <book-slug>
#   activate-book.sh --clear
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

usage() {
    cat <<EOF
Usage:
  $(basename "$0") <book-slug>
  $(basename "$0") --clear
EOF
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

case "$1" in
    --clear)
        clear_active_book_slug
        log "[activate-book] Cleared active book"
        exit 0
        ;;
    -h|--help)
        usage
        exit 0
        ;;
esac

set_active_book_slug "$1"
log "[activate-book] Active book set to: $1"
