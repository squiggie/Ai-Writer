#!/usr/bin/env bash
# =============================================================================
# generate-book.sh — Full pipeline: idea → architect → write → Astro build → deploy
#
# Usage: generate-book.sh [book-slug] [--chapters-per-run N|--all]
#   If no slug is given, uses today's date: book-YYYY-MM-DD
#   Resumes safely if interrupted — skips any phase whose output files exist
# =============================================================================
set -euo pipefail
source "$(dirname "$0")/config.sh"
check_deps

usage() {
    cat <<EOF
Usage: $(basename "$0") [book-slug] [--chapters-per-run N|--all]

Options:
  --chapters-per-run N   Write at most N unfinished chapters this run
  --all                  Write all remaining chapters this run
  -h, --help             Show this help
EOF
}

# ── Setup ─────────────────────────────────────────────────────────────────────
DATE=$(date +%Y-%m-%d)
BOOK_SLUG=""
CHAPTERS_PER_RUN_LIMIT="$CHAPTERS_PER_RUN"

while [ "$#" -gt 0 ]; do
    case "$1" in
        --chapters-per-run)
            shift
            [ "$#" -gt 0 ] || fail "Missing value for --chapters-per-run"
            CHAPTERS_PER_RUN_LIMIT="$1"
            ;;
        --all)
            CHAPTERS_PER_RUN_LIMIT=0
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

BOOK_SLUG="${BOOK_SLUG:-book-$DATE}"
NOVEL_DIR="$NOVELS_DIR/$BOOK_SLUG"
LOG_FILE="$LOG_DIR/book-$DATE.log"

case "$CHAPTERS_PER_RUN_LIMIT" in
    ''|*[!0-9]*)
        fail "chapters-per-run must be a non-negative integer"
        ;;
esac

mkdir -p "$LOG_DIR" "$NOVEL_DIR/chapters" "$NOVEL_DIR/characters"

# Tee all output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

log "================================================================"
log "Starting: $BOOK_SLUG"
log "Novel dir: $NOVEL_DIR"
if [ "$CHAPTERS_PER_RUN_LIMIT" -eq 0 ]; then
    log "Chapter batch: all remaining chapters"
else
    log "Chapter batch: up to $CHAPTERS_PER_RUN_LIMIT unfinished chapters"
fi
log "================================================================"

# ── Phase 1: Ideation ─────────────────────────────────────────────────────────
if [ ! -f "$NOVEL_DIR/idea.md" ]; then
    log ""
    log "[Phase 1/5] Generating novel concept..."

    run_codex "$NOVELS_DIR" \
        "Read $AIWRITER_DIR/genres.md in full — all approved genre profiles, their category labels, comp authors, POV, rhythm, tone, and Christian worldview integration approach.

Read $AIWRITER_DIR/diversity-tracker.md — understand what genres, POVs, tones, settings, and protagonist types have already been used. Note the last 3 books specifically.

Select one approved genre profile from genres.md that maximizes contrast with recent entries:
- Different genre from the last 3 books
- Different POV from the last 2 books
- Different tone from the last 2 books
- Different setting type from the last 3 books

Generate a completely original novel concept with a Christian worldview woven naturally into its themes (not preached, shown through consequence and character choice).

Save to $BOOK_SLUG/idea.md with exactly this structure:
---
title: [Novel Title]
slug: [URL-safe title slug, lowercase with hyphens, based on the novel title and not the dated folder name]
source_slug: $BOOK_SLUG
category: [Sci-Fi / Fantasy / Thriller / Military SF / Space]
genre: [exact genre profile name from genres.md]
pov: [First person / Third limited / Third omniscient / Multiple / Epistolary]
tone: [primary tone descriptor — one or two words]
setting_type: [Contemporary / Near-future / Historical / Fantasy / Rural / Urban / etc.]
comp_authors: [Author 1, Author 2, Author 3]
---

## Premise
[One paragraph — the situation, the protagonist, what is at stake]

## Protagonist
Name: [name]
Role: [what they do in the world]
Ghost/wound: [what happened to them]
Lie: [what they believe because of it]
Truth: [what they must learn]
Arc: [how they change]

## Antagonist
Name: [name]
Function: [what role they play — may be institutional, not personal]

## Themes
1. [Theme one]
2. [Theme two]
3. [Theme three]

## Christian Worldview Integration
[How faith, grace, redemption, or moral clarity appears — specific, not generic]

## Setting
[Time period, place, world rules if applicable]"
else
    log "[Phase 1/6] idea.md exists — skipping"
fi

# ── Phase 2: Architect ────────────────────────────────────────────────────────
if [ ! -f "$NOVEL_DIR/memory.md" ]; then
    log ""
    log "[Phase 2/5] Running Architect..."

    log "  Generating style guide..."
    run_codex "$NOVEL_DIR" \
        "Read $AIWRITER_DIR/agents.md — the Architect Agent section and the per-novel style guide template.
Read $AIWRITER_DIR/genres.md — find the full approved genre profile that matches the genre in idea.md.
Read idea.md.

Generate style-guide.md for this novel using the template in agents.md.
The style guide must be specific to THIS novel — this protagonist, this world, this voice.
Do not write generic guidelines. Every rule should reference something specific about this book.

Required sections:
1. Genre Profile — which genre, why it fits this story
2. Comp Authors — 3-4 authors from the genre profile, one sentence each on what they contribute to THIS novel specifically
3. POV and Narrative Distance — exact specification
4. Sentence Rhythm — default rhythm, how it changes under pressure, what that transition marks
5. Tone and Emotional Register — primary tone, what the reader should feel
6. Protagonist Voice Signature — sentence rhythm, vocabulary register, metaphor sources, what they never say directly, what they do instead
7. Scene Break Policy — maximum breaks for this novel, what warrants one
8. What This Novel Is Not — 4-5 specific things to avoid that would pull toward other genres or generic AI-fiction patterns

Save to style-guide.md. Output nothing else."

    log "  Updating diversity tracker..."
    run_codex "$AIWRITER_DIR" \
        "Read novels/$BOOK_SLUG/idea.md and novels/$BOOK_SLUG/style-guide.md.

Add a new entry to diversity-tracker.md following the exact format of existing entries:
### [Book entry for $BOOK_SLUG]
- date: $DATE
- slug: $BOOK_SLUG
- category: [from idea.md]
- genre: [from idea.md]
- pov: [from idea.md]
- tone: [from idea.md]
- setting_type: [from idea.md]
- protagonist_type: [brief description from idea.md]
- sentence_rhythm: [from style-guide.md]
- christian_integration: [from idea.md]
- structure: [will be filled by outline — leave as TBD for now]
- comp_authors: [from idea.md]

Save the updated diversity-tracker.md. Output nothing else." \
        "$CODEX_FAST_SLEEP"

    log "  Generating outline..."
    run_codex "$NOVEL_DIR" \
        "Read $AIWRITER_DIR/agents.md — the Architect Agent section including all six structure options and their key beats.
Read idea.md and style-guide.md.

Select the story structure that best fits this novel's genre and emotional arc.
Decide how many chapters the story needs — between $CHAPTERS_MIN and $CHAPTERS_MAX. Let the structure drive the count: a tighter thriller may need fewer; a sprawling epic more. Choose the number that serves the story, not the maximum.

Generate outline.md with:

# [Novel Title] — Outline

## Structure
Chosen structure: [name]
Chapter count: [N]
Rationale: [why this structure and this chapter count serve this story]

## Chapter Outline

For each chapter:

### Chapter N: [Title]
- Beat: [which structural beat this serves]
- POV: [character name]
- Timeline: [when in the story]
- Opening: [how the chapter starts — specific, not generic]
- Core scene: [the main event or revelation]
- Emotional beat: [what the reader should feel]
- Ending: [how it ends — tension, question, consequence]
- Stakes: [what changes or is at risk]

Save to outline.md. Output nothing else."

    log "  Generating bible and characters..."
    run_codex "$NOVEL_DIR" \
        "Read $AIWRITER_DIR/agents.md Architect section.
Read idea.md, style-guide.md, outline.md.

Generate four files:

1. bible.md — World rules:
   - Physical world (geography, technology, systems in place)
   - Social/political structures
   - Rules and limits (what technology/magic/systems cannot do)
   - Cultural and religious elements
   - Historical timeline relevant to the story
   - Any specific world details the outline requires

2. characters/protagonist.md — Full character sheet:
   - Name, age, physical description
   - Ghost/wound/lie/truth arc (detailed)
   - Voice signature (specific sentence patterns, vocabulary, what they notice)
   - Relationships at story start
   - Internal state at Chapter 1
   - How they change chapter by chapter (brief arc summary)

3. characters/antagonist.md — Full sheet including motivation and method

4. characters/supporting.md — Key supporting characters with role, voice note, and relationship to protagonist

Save all four files. Output nothing else."

    log "  Generating themes and initializing memory..."
    run_codex "$NOVEL_DIR" \
        "Read idea.md, outline.md, bible.md, characters/protagonist.md.

Generate two files:

1. themes.md:
   - For each of the three themes: where it first appears, where it develops, where it resolves
   - Map each theme to specific chapters
   - Note where Christian worldview moments appear (grace, redemption, moral clarity, providence)
   - Note any recurring motifs and their planned instances

2. memory.md — Initialize with:
   ## Novel Summary
   [Title, genre, premise, protagonist, antagonist]

   ## Chapter Progress Log
   [One entry per chapter in outline.md, all marked TODO, with chapter number and title]

   ## Continuity Flags
   [Empty — populated as chapters are written]

   ## Character State
   [Starting state for protagonist and key characters]

   ## World State
   [Starting conditions]

   ## Revision History
   [Empty]

Save both files. Output nothing else."

    # Update diversity tracker with structure
    STRUCTURE=$(grep -i "^Chosen structure:" "$NOVEL_DIR/outline.md" 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo "Unknown")
    run_codex "$AIWRITER_DIR" \
        "Read diversity-tracker.md. Find the entry for $BOOK_SLUG and update the structure field to: $STRUCTURE. Save the updated file. Output nothing else." \
        "$CODEX_FAST_SLEEP"
else
    log "[Phase 2/5] Architect files exist — skipping"
fi

# ── Phase 3: Write all chapters ───────────────────────────────────────────────
# Read actual chapter count from outline.md (Architect chose it within the configured range)
CHAPTERS_PER_BOOK=$(chapter_count_from_outline "$NOVEL_DIR/outline.md" "$CHAPTERS_MAX")
# Validate: clamp to configured range
if [ "$CHAPTERS_PER_BOOK" -lt "$CHAPTERS_MIN" ] || [ "$CHAPTERS_PER_BOOK" -gt "$CHAPTERS_MAX" ] 2>/dev/null; then
    log "  Chapter count $CHAPTERS_PER_BOOK out of range — defaulting to $CHAPTERS_MIN"
    CHAPTERS_PER_BOOK="$CHAPTERS_MIN"
fi

log ""
if [ "$CHAPTERS_PER_RUN_LIMIT" -eq 0 ]; then
    log "[Phase 3/5] Writing remaining chapters (up to $CHAPTERS_PER_BOOK total)..."
else
    log "[Phase 3/5] Writing up to $CHAPTERS_PER_RUN_LIMIT unfinished chapters this run..."
fi

CHAPTERS_WRITTEN_THIS_RUN=0
for i in $(seq 1 "$CHAPTERS_PER_BOOK"); do
    PADDED=$(printf '%02d' "$i")
    FINAL="$NOVEL_DIR/chapters/chapter-${PADDED}.md"

    if [ -f "$FINAL" ] && grep -q "status: FINAL" "$FINAL" 2>/dev/null; then
        log "  Chapter $i — already FINAL, skipping"
        continue
    fi

    if [ "$CHAPTERS_PER_RUN_LIMIT" -gt 0 ] && [ "$CHAPTERS_WRITTEN_THIS_RUN" -ge "$CHAPTERS_PER_RUN_LIMIT" ]; then
        log "  Reached chapter batch limit for this run"
        break
    fi

    TITLE=$(chapter_title_from_outline "$NOVEL_DIR/outline.md" "$i" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    [ -n "$TITLE" ] || TITLE="Chapter $i"

    log "  Chapter $i: $TITLE"
    bash "$SCRIPTS_DIR/generate-chapter.sh" "$NOVEL_DIR" "$i" "$TITLE"
    CHAPTERS_WRITTEN_THIS_RUN=$((CHAPTERS_WRITTEN_THIS_RUN + 1))
done

log ""
if [ "$CHAPTERS_WRITTEN_THIS_RUN" -eq 0 ]; then
    log "[Phase 3/5] No unfinished chapters processed"
else
    log "[Phase 3/5] Completed $CHAPTERS_WRITTEN_THIS_RUN chapter(s) this run"
fi

# ── Phase 4: Build site ───────────────────────────────────────────────────────
log ""
log "[Phase 4/5] Building Astro site..."
bash "$SCRIPTS_DIR/build-site.sh" "$NOVEL_DIR" "$BOOK_SLUG"

# ── Phase 5: Deploy ───────────────────────────────────────────────────────────
log ""
log "[Phase 5/5] Deploying to GitHub Pages..."
bash "$SCRIPTS_DIR/deploy.sh" "$BOOK_SLUG"

log ""
log "================================================================"
log "Complete: $BOOK_SLUG"
log "Live at: $GITHUB_PAGES_URL"
log "================================================================"
