# AI Writer Project

A four-agent multi-agent system for writing science fiction novels with a Christian worldview. The system includes a pre-writing phase (Architect) that prepares complete story foundation before drafting begins, followed by Writer, Developmental Editor, and Line Editor.

---

## Project Structure

```
aiwriter/
├── claude.md          # This file - project overview and structure
├── agents.md          # Agent definitions and workflows
├── memory.md          # Shared story context and memory
├── novels/            # Novel projects
│   └── [novel-name]/
│       ├── chapters/      # Individual chapter files
│       ├── outline.md     # Story outline and beats (Architect output)
│       ├── bible.md       # World rules, history, society (Architect output)
│       ├── themes.md      # Thematic mapping (Architect output)
│       └── characters/    # Character sheets (Architect output)
│           ├── protagonist.md
│           ├── antagonist.md
│           └── supporting.md
└── output/            # Compiled/final manuscripts
    └── [novel-name]/
        └── manuscript.md
```

---

## Main Elements

### Four Agents
1. **Architect Agent** - Pre-writing: structure selection, outlining, world/character design
2. **Writer Agent** - Collaborative prose generation with craft excellence
3. **Developmental Editor Agent** - Structural, character, world, thematic review
4. **Line Editor Agent** - Grammar, style, and content compliance

### Core Files
- `agents.md` - All agent specifications and handoff protocols
- `memory.md` - Shared context for story elements
- `claude.md` - Project structure and workflow documentation

### Output Files
- Chapter files in Markdown with frontmatter
- Compiled manuscripts in `output/` directory

---

## File Organization

### Chapter Files
Location: `novels/[novel-name]/chapters/chapter-NN.md`

Format:
```markdown
---
chapter: 1
title: The Beginning
pov: John
word_count: 2500
timeline_position: Day 1, Morning
beat_source: outline.md section X
---

Chapter content...
```

### Outline Files
Location: `novels/[novel-name]/outline.md`

Contains:
- Chosen story structure with rationale
- Market pattern notes (comparable titles)
- Chapter-by-chapter beats with emotional stakes
- Major plot points aligned to structure
- Character introduction schedule

### Bible Files
Location: `novels/[novel-name]/bible.md`

Contains:
- Technology rules with limits and costs
- Social/political structures
- Cultural/religious elements
- Historical timeline
- World consistency constraints

### Themes Files
Location: `novels/[novel-name]/themes.md`

Contains:
- Primary themes and their progression
- Christian worldview integration points
- Motif and symbol tracking
- Per-chapter thematic beats

### Character Files
Location: `novels/[novel-name]/characters/`

Contains:
- Ghost/wound, lie, truth, arc for each character
- Voice signatures (rhythm, vocabulary, metaphors)
- Motivation hierarchy (want vs. need)
- First appearance and status

### Memory File
Location: `memory.md` (project root)

Contains:
- Character profiles
- Timeline
- World rules
- Plot points
- Thematic elements
- Story structure tracking
- Chapter progress log

---

## Writing Workflow

### Step 1: Architect Pre-Writing Phase
The Architect Agent completes ALL foundation work before Chapter 1:

1. **Market Pattern Analysis** (Light)
   - Identify 3-5 comparable bestseller titles
   - Extract hook techniques, chapter patterns, emotional rhythm

2. **Structure Selection**
   - Choose from: Freytag, Hero's Journey, Fichtean, Story Circle, Seven-Point, Non-Linear
   - Document rationale and beat map

3. **Character Architecture**
   - Build full profiles with ghost/wound, lie, truth, arc
   - Establish voice signatures

4. **World-Building Bible**
   - Technology rules, society, culture, history
   - Limits and costs defined

5. **Thematic Mapping**
   - Plot theme appearances per chapter
   - Map Christian worldview integration points

6. **Detailed Outline**
   - Chapter-by-chapter beats with emotional stakes
   - Structure-aligned progression

### Step 2: Initialize Project
```bash
mkdir -p novels/[novel-name]/chapters
mkdir -p novels/[novel-name]/characters
mkdir -p output/[novel-name]
# Architect outputs: outline.md, bible.md, themes.md, characters/
cp memory.md novels/[novel-name]/memory.md
```

### Step 3: Write Chapters
For each chapter:

1. **Writer Agent** drafts the chapter based on outline beat
   - References character files for voice consistency
   - Follows craft excellence guidelines
   - Integrates bestseller patterns

2. **Developmental Editor** reviews for:
   - Story structure integrity (chosen model)
   - Character arc progression
   - World-building logic
   - Thematic integrity
   - Christian worldview integration
   - Bestseller compliance

3. **Line Editor** polishes for:
   - Grammar and spelling
   - Sentence structure
   - Style compliance (dialog tags, AI patterns)
   - Content standards

4. Chapter marked FINAL and saved to `chapters/`

### Step 4: Update Memory
After each chapter:
- Add new character details
- Update timeline
- Note new world rules established
- Track plot progression
- Log chapter status

---

## Arrangement and Compilation

### Chapter Ordering
Chapters are numbered sequentially:
- `chapter-01.md`
- `chapter-02.md`
- `chapter-03.md`
- etc.

### Compilation Command
To compile final manuscript:

```bash
# Concatenate all chapters in order
cat novels/[novel-name]/chapters/chapter-*.md > output/[novel-name]/manuscript.md
```

### Frontmatter Stripping (Optional)
For clean manuscript output without frontmatter:

```bash
# Use a script or tool to remove --- blocks between --- markers
# Result: plain prose manuscript
```

---

## Story Structure Options

The Architect selects one of six structures:

| Structure | Best For | Key Beats |
|-----------|----------|-----------|
| Freytag's Pyramid | Dramatic/tragic tales | Exposition → Rising Action → Climax → Falling Action → Denouement |
| Hero's Journey | Epic sci-fi, transformation | Call → Trials → Abyss → Transformation → Return |
| Fichtean Curve | Fast-paced thrillers | Crisis → Escalating Crises → Climax (~2/3) |
| Dan Harmon's Circle | Character-driven, cyclical | Comfort → Want → Chaos → Adaptation → Return Changed |
| Seven-Point Structure | Plot-driven, contrast | Hook → Turn 1 → Pinch 1 → Midpoint → Pinch 2 → Turn 2 → Resolution |
| Non-Linear | Mystery, ensemble, thematic | Reverse chronology, circular, modular |

---

## General Project Context

### Genre Specifications
- **Primary**: Science Fiction
- **Worldview**: Christian (general principles)
- **Tone**: Humanistic, authentic, non-preachy

### Content Standards
- No cursing or obscene language
- No gratuitous violence or gore
- No explicit sexual content
- Tasteful mentions allowed only when necessary for character/scene development

### Style Guidelines
- Avoid AI-detected writing patterns
- Avoid em dashes (—) and en dashes (–) where possible
- Avoid witty one-liners at chapter/section endings
- Dialog tags varied with action beats and specific verbs
- Dialog used for: slowing pace, character/scene development
- Exposition used for: accelerating pace, moving plot forward
- Show-don't-tell through action, sensory details, character choices

### Agent System Design
- **Architect**: Pre-writing foundation with structure selection
- **Option B** Writer: Collaborative, incremental writing with approval gates
- **Option C** Developmental Editor: Comprehensive structural and thematic review
- **Option C** Line Editor: Full grammar, style, and content compliance
- **Option A** Handoff: Sequential pipeline (Architect → Writer → Dev → Line → Final)
- **Option B** Output: Markdown with frontmatter per chapter
- **Option C** Memory: Shared story context + agent-specific workflow files
- **Option A** Memory Tracking: Characters, timeline, world rules, plot points, themes
- **Option A** Worldview: General Christian principles (redemptive, hopeful, moral clarity)

---

## Quick Start

1. Review `agents.md` for all four agent specifications
2. Architect Agent runs pre-writing phase first
3. Review `memory.md` for story context template
4. Create new novel directory under `novels/`
5. Architect produces: outline.md, bible.md, themes.md, characters/
6. Writer Agent begins Chapter 1 with complete foundation
7. Follow sequential pipeline for each chapter
8. Compile finished manuscript to `output/`

---

## One-Shot Bestseller Goal

This system is designed for "first draft quality" output — the manuscript is as close to bestseller-ready as possible from the first pass:

1. **Architect** ensures foundation is solid (structure, characters, world, themes)
2. **Writer** executes with craft excellence and bestseller pattern awareness
3. **Developmental Editor** verifies structural integrity and earned transformation
4. **Line Editor** polishes to professional standards

The result: a novel that reads like a bestseller because the architecture, prose, and emotional beats are built to market standards from the start.
