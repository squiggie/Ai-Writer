#!/usr/bin/env bash
# =============================================================================
# generate-chapter.sh — Run a single chapter through the full three-agent pipeline
#
# Usage: generate-chapter.sh <novel_dir> <chapter_num> <chapter_title>
# Example: generate-chapter.sh /path/to/novels/book-2026-03-22 5 "The Quiet Shore"
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"

# ── Args ──────────────────────────────────────────────────────────────────────
NOVEL_DIR="${1:?Usage: generate-chapter.sh <novel_dir> <chapter_num> <chapter_title>}"
CHAPTER_NUM="${2:?Missing chapter number}"
CHAPTER_TITLE="${3:?Missing chapter title}"
PADDED=$(printf '%02d' "$CHAPTER_NUM")

# ── File paths ────────────────────────────────────────────────────────────────
DRAFT="$NOVEL_DIR/chapters/chapter-${PADDED}-draft.md"
DEV_REVIEW="$NOVEL_DIR/chapters/chapter-${PADDED}-dev-review.md"
LINE_REVIEW="$NOVEL_DIR/chapters/chapter-${PADDED}-line-review.md"
FINAL="$NOVEL_DIR/chapters/chapter-${PADDED}.md"

clog() { log "[Ch.${PADDED}] $*"; }

# ── Skip if already complete ──────────────────────────────────────────────────
if [ -f "$FINAL" ] && grep -q "status: FINAL" "$FINAL" 2>/dev/null; then
    clog "Already FINAL — skipping"
    exit 0
fi

clog "Starting: $CHAPTER_TITLE"
mkdir -p "$NOVEL_DIR/chapters"

# ── Writer Agent ──────────────────────────────────────────────────────────────
if [ ! -f "$DRAFT" ]; then
    clog "Writer Agent..."
    run_codex "$NOVEL_DIR" \
        "You are the Writer Agent for this novel.

STEP 1: Read $AIWRITER_DIR/agents.md — specifically the Writer Agent section for your full role, responsibilities, and craft guidelines.
STEP 2: Read style-guide.md in this directory — this is the per-novel style guide for THIS book. It defines comp authors, voice signature, sentence rhythm, tone, scene break policy, and what this novel is not. Follow it exactly.
STEP 3: Read memory.md for current novel state, continuity flags, and what has happened so far.
STEP 4: Read outline.md for the Chapter $CHAPTER_NUM beat, emotional stakes, and structural position.
STEP 5: Find the two most recently dated chapter-XX.md files in chapters/ (not draft/review files) and read them for voice and continuity.

Now write Chapter $CHAPTER_NUM: $CHAPTER_TITLE.

Requirements:
- Follow the voice signature in style-guide.md precisely — this protagonist sounds like themselves, not like a generic literary narrator
- Maximum two scene breaks (---) per chapter, one preferred; never as a substitute for writing a transition
- No isolated one-sentence paragraphs unless load-bearing
- No em dashes
- No witty chapter endings — end on tension, consequence, or an open question
- ${WORDS_MIN}–${WORDS_MAX} words; let the chapter's emotional weight guide placement within that range — quieter chapters can sit lower, climactic chapters higher
- YAML frontmatter: chapter number, title, pov, word_count, timeline_position, beat_source, status: draft

Save the complete chapter with frontmatter to chapters/chapter-${PADDED}-draft.md.
Output the chapter only — no commentary before or after."
fi

# ── Developmental Editor ──────────────────────────────────────────────────────
if [ ! -f "$DEV_REVIEW" ]; then
    clog "Developmental Editor..."
    run_codex "$NOVEL_DIR" \
        "You are the Developmental Editor for this novel.

STEP 1: Read $AIWRITER_DIR/agents.md — the Developmental Editor section for your full role, checklist, and output format.
STEP 2: Read memory.md and outline.md for context on where this chapter sits in the novel's arc.
STEP 3: Read style-guide.md for this novel's voice and style requirements.
STEP 4: Read chapters/chapter-${PADDED}-draft.md — this is the chapter to review.

Produce the full developmental review following the output format in agents.md exactly.
Pay particular attention to:
- Whether the chapter's pacing matches its emotional weight (key scenes must slow; procedural scenes can move)
- Whether the protagonist's body is present in emotional moments
- Whether dialogue contains physical beats, not only information transfer
- Whether scene breaks are justified or substituting for written transitions
- Whether the voice matches style-guide.md

Save the complete review to chapters/chapter-${PADDED}-dev-review.md.
Output the review document only — no commentary before or after."
fi

# ── Line Editor ───────────────────────────────────────────────────────────────
if [ ! -f "$FINAL" ]; then
    clog "Line Editor..."
    run_codex "$NOVEL_DIR" \
        "You are the Line Editor for this novel.

STEP 1: Read $AIWRITER_DIR/agents.md — the Line Editor section for your full role, checklist, and output format.
STEP 2: Read style-guide.md — specifically the 'Scenes to Protect' section if present; do not revise those passages without cause.
STEP 3: Read chapters/chapter-${PADDED}-draft.md.
STEP 4: Read chapters/chapter-${PADDED}-dev-review.md for the developmental concerns to address.

Produce two outputs:
1. The line edit record — save to chapters/chapter-${PADDED}-line-review.md
2. The final polished chapter — save to chapters/chapter-${PADDED}.md with status: FINAL in YAML frontmatter

For the final chapter:
- Address all concerns from the dev review
- Remove any em dashes
- Absorb isolated one-sentence paragraphs unless load-bearing
- Ensure sentence rhythm varies correctly for this novel (per style-guide.md)
- Verify scene breaks are justified; convert unjustified breaks to prose transitions
- Do not alter passages the dev review marked as working correctly

Output nothing else — only the two saved files."
fi

# ── Memory Update ─────────────────────────────────────────────────────────────
clog "Updating memory..."
run_codex "$NOVEL_DIR" \
    "Read chapters/chapter-${PADDED}.md and memory.md.

Update memory.md with:
1. Mark Chapter $CHAPTER_NUM as FINAL in the Chapter Progress Log
2. Add any new continuity flags introduced in this chapter (character states, objects introduced, relationships changed, locations visited)
3. Add an entry to the Revision History: date, chapter, status FINAL
4. Update any character or world state entries that changed in this chapter

Save the updated memory.md. Output nothing else." \
    "$CODEX_FAST_SLEEP"

clog "Complete — $CHAPTER_TITLE"
