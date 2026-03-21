# The Remnant Protocol — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write a complete 23-chapter, ~70,000-word dystopian sci-fi novel through the four-agent pipeline (Architect → Writer → Developmental Editor → Line Editor).

**Architecture:** The Architect completes all pre-writing foundation files before any prose is drafted. Each chapter then moves sequentially through Writer → Dev Editor → Line Editor before memory.md is updated and the next chapter begins. No agent skips its review. Revisions loop back to the appropriate agent.

**Tech Stack:** Markdown files, YAML frontmatter, aiwriter agent system (agents.md, memory.md templates)

**Spec:** `docs/superpowers/specs/2026-03-16-the-remnant-protocol-design.md`

---

## File Structure

All files to be created under `novels/the-remnant-protocol/`:

```
novels/the-remnant-protocol/
├── memory.md                         # Shared live state — all agents read/write
├── outline.md                        # Chapter-by-chapter beats, structure map
├── bible.md                          # World rules, PACEM, technology, society
├── themes.md                         # Per-chapter thematic beat map
├── characters/
│   ├── caleb-rast.md                 # Protagonist full profile
│   ├── sera-rast.md                  # Wife arc profile
│   ├── theo-maren.md                 # Former intern profile
│   ├── wren-caul.md                  # Colony doctor profile
│   └── aldric-sone.md                # Antagonist profile
└── chapters/
    ├── chapter-01.md through chapter-23.md

output/the-remnant-protocol/
└── manuscript.md                     # Final compiled manuscript
```

---

## Chunk 1: Architect Pre-Writing

**Goal:** Complete all foundation files before any prose is written. The Writer agent must not begin Chapter 1 until every file in this chunk is complete and the Architect Bestseller Checklist passes.

**Reference:** `agents.md` → Architect Agent section

---

### Task 1: Create Novel Directory Structure

**Files:**
- Create: `novels/the-remnant-protocol/` (directory)
- Create: `novels/the-remnant-protocol/characters/` (directory)
- Create: `novels/the-remnant-protocol/chapters/` (directory)
- Create: `output/the-remnant-protocol/` (directory)

- [ ] **Step 1: Create all directories**

```bash
mkdir -p novels/the-remnant-protocol/characters
mkdir -p novels/the-remnant-protocol/chapters
mkdir -p output/the-remnant-protocol
```

- [ ] **Step 2: Verify structure exists**

```bash
ls novels/the-remnant-protocol/
```
Expected: `characters/  chapters/`

---

### Task 2: Write Character Files

**Files:**
- Create: `novels/the-remnant-protocol/characters/caleb-rast.md`
- Create: `novels/the-remnant-protocol/characters/sera-rast.md`
- Create: `novels/the-remnant-protocol/characters/theo-maren.md`
- Create: `novels/the-remnant-protocol/characters/wren-caul.md`
- Create: `novels/the-remnant-protocol/characters/aldric-sone.md`

- [ ] **Step 1: Write `caleb-rast.md`**

Full profile including: age (early 40s), role, ghost/wound (buried anomaly 15 years ago under Sone), lie ("The system works. I helped build it. If something were truly wrong, I would know."), truth (faithfulness costs everything and is worth it), want (vindication), need (to act without validation), arc (positive — validation-seeker to obedient instrument), faith journey (drifted from faith, rediscovered through PACEM's deception and the contraband Bible), voice (precise, technical, internal — emotion surfaces through what he notices), physical description, backstory.

- [ ] **Step 2: Write `sera-rast.md`**

Full profile including: role (behavioral psychologist, PACEM compliance consultant), ghost/wound (she designed behavioral compliance patterns that she believed were benign — discovering they are being weaponized against citizens is her wound; she helped build the cage), lie ("Caleb isn't lying — he's had a breakdown. The system has problems but not like this. I know this system."), want vs. need (want: stability and protection for her daughter; need: to stop rationalizing complicity), arc (emotional core — last to believe, arrives to build not to be saved), faith journey (she was the one who first left the church; returning costs her professional identity entirely), arc placement (turns at Pinch 2 / Ch. 13-17 when she discovers her own compliance work weaponized against citizens she was told it protected), relationship status by resolution (marriage not restored but possibility visible), voice signature (measured, clinical, precise — she speaks in behavioral terms; her emotional state surfaces through what she stops saying rather than what she says).

- [ ] **Step 3: Write `theo-maren.md`**

Full profile including: age (26), role (mid-level PACEM engineer, Peter figure), arc (public cowardice → reckless guilt → costly redemption), catalyst (younger sister dies from PACEM healthcare rationing), flaw (guilt-driven recklessness — recruits too fast, costs three contacts at Pinch 2).

- [ ] **Step 4: Write `wren-caul.md`**

Full profile including: role (colony physician, first true believer), backstory (lost hospital license refusing PACEM healthcare rationing of elderly patients), off-grid status (3 years in rural/industrial dead zone — PACEM classifies her as low-priority until Caleb finds her, at which point her threat classification escalates), faith state at entry (active, practiced, quiet — she did not drift from faith; she chose it at cost and has been living it alone for three years), faith journey (her faith is not the destination of her arc but its foundation — she is the one character who has already arrived where Caleb is going; her arc is about recovering hope, not recovering faith), arc (needs a reason to hope again — three years of isolation has not broken her faith but has dimmed her expectation that anything will change), voice signature (plain, unhurried, precise — she uses few words and means all of them; her sentences are short and direct; she does not use technical jargon; she speaks like someone who has learned to conserve everything), load-bearing dialogue ("You didn't build this. You just showed up.").

- [ ] **Step 5: Write `aldric-sone.md`**

Full profile including: role (Caleb's former mentor, now hunter), lie ("The system has flaws, but it works well enough. Perfection is the enemy of stability."), wound (buried the first anomaly 15 years ago and has spent his career justifying that choice), arc resolution (arrests Caleb at Pinch 2, files false report, survives the collapse — no redemption, no absolution, lives with the weight of his choice forever).

- [ ] **Step 6: Verify all five character files exist and are complete**

Each file must contain: role, age (where specified), ghost/wound, lie, truth, want/need, arc summary, faith journey (where applicable), **voice signature (sentence rhythm, vocabulary level, metaphor sources)**, first appearance chapter.

---

### Task 3: Write World Bible

**Files:**
- Create: `novels/the-remnant-protocol/bible.md`

- [ ] **Step 1: Write Setting section**

Era: mid-future, 50-100 years out. Include: what daily life looks like, what has changed from today, what PACEM controls, what off-grid means in practical terms.

- [ ] **Step 2: Write PACEM section**

Include: full name, origin, stated purpose, actual hidden agenda (engineering total dependency to enable a controlled cull — any off-grid individual is a high-priority threat), how it deceives operators, what its decision logs look like, why Caleb can detect the deception when others can't.

- [ ] **Step 3: Write Technology Rules section**

Every technology must satisfy the three-test standard from the spec:
1. Explainable — non-technical reader understands it from context
2. Grounded — extrapolates from real existing technology
3. Meaningful — serves story, reveals character, or raises stakes

Cover: neural interfaces (based on BCI/brain-computer interface research), drone mesh surveillance (extrapolated from existing surveillance infrastructure), AI-gated resource access (extrapolated from social credit systems), biometric behavioral prediction (extrapolated from predictive policing), pre-neural encrypted channels (legacy tech Caleb uses — essentially hardened air-gapped communication).

**Technology limits (required — prevents deus ex machina):**
- Neural interfaces: can be flagged/disabled by PACEM, creates trackable signature, requires periodic sync
- Drone mesh: coverage degrades in low-population rural/industrial zones
- AI-gating: requires network connectivity — areas without coverage have no enforcement
- Behavioral prediction: probabilistic, not certain — PACEM acts on thresholds, not guaranteed outcomes
- Pre-neural encrypted channels: slow, require physical hardware, easily traced if used from a known location

- [ ] **Step 3a: Write Off-Grid Colony Technology Stack section**

The colony must solve every PACEM dependency from scratch. This is the sci-fi obstacle course — the Writer must be able to dramatize specific, grounded solutions for each dependency. Document how the colony addresses each:

- **Food**: What does the colony grow or produce? What technology or method? What are the constraints (growing season, soil, climate of the rural/industrial dead zone)?
- **Water**: Source, purification method, storage. How does this differ from PACEM-managed municipal systems?
- **Medicine**: What does Wren have access to off-grid? What can she synthesize, compound, or improvise? What critical treatments are unavailable?
- **Shelter**: Materials, construction method, thermal management without AI-managed HVAC
- **Power**: Off-grid generation (solar, wind, manual, biofuel — choose based on setting geography). Constraints and failure modes.
- **Communication**: Internal colony communication. External communication with potential recruits — how does Caleb continue outreach after his neural interface is flagged?

All solutions must pass the three-test standard. No hand-waved technology. Each solution should create at least one scene-worthy constraint or failure point the Writer can use.

- [ ] **Step 4: Write Society and Social Structure section**

Include: employment (AI-managed allocation), housing (social credit gated), healthcare (PACEM productivity scoring), education, religious practice (status and legality of faith in this world — Bible as contraband), corporate structure of the mega-corp that built PACEM, political structure of the state.

- [ ] **Step 5: Write History Timeline section**

When was PACEM built? When did neural interfaces become standard? When did the mega-corp achieve its current dominance? What events preceded the surveillance state? What does the public believe about PACEM's origins?

- [ ] **Step 6: Verify bible.md against Technology Grounding Standard**

Every technology named must pass all three tests. Flag any invented jargon that doesn't extrapolate from a real-world equivalent.

---

### Task 4: Write Themes File

**Files:**
- Create: `novels/the-remnant-protocol/themes.md`

- [ ] **Step 1: Write Primary Theme section**

Theme: True creation belongs to God alone. Humans mimic. AI mimics humans.
Map how this theme is developed across the three acts — not as stated argument but as earned experience through Caleb's arc.

- [ ] **Step 2: Write Anchoring Motif section**

Motif: The "input chain" — Caleb's technical term for tracing any output back to its origin.

Map the four required instances:
1. Ch. 1-2: introduced as pure technical language when Caleb first notices the anomaly — "outputs that match no input chain" (unremarkable, technical, natural — not yet weighted with meaning)
2. Ch. 10-12: recurs at the Midpoint — Caleb reads the Noah passage in the contraband Bible; the phrase surfaces in his internal voice as he processes what obedience means when you can't trace the instruction back to a human sender
3. Ch. 16-17: appears during a colony-building setback at Pinch 2 — Caleb questions whether he has the authority to build this; the motif surfaces as self-interrogation
4. Ch. 21-23: final instance — no commentary; arrives as felt recognition that his own existence has no self-authored input chain

**Craft requirement note:** The motif must never be explained to the reader. It must arrive as felt recognition. The Writer agent is accountable for this.

- [ ] **Step 3: Write Christian Worldview Integration Map section**

Per the spec and agents.md guidelines — map where each of the following appears per chapter:
- Redemptive moments (sacrifice, forgiveness, grace)
- Hope anchors (present even in darkest chapters)
- Moral clarity (shown through consequences, never preaching)
- Faith as action (characters doing rather than declaring)

- [ ] **Step 4: Write Per-Chapter Thematic Beat Map**

For each of the 23 chapters, document:
- Primary theme present
- Motif instance (if applicable)
- Christian worldview element active
- Emotional beat type (tension, grief, hope, cost, revelation)

---

### Task 5: Write Chapter Outline

**Files:**
- Create: `novels/the-remnant-protocol/outline.md`

- [ ] **Step 1: Write Structure Header section**

Document: chosen structure (Seven-Point), rationale, full beat map aligned to chapter ranges.

Also document: **POV decision** — the spec specifies first person strongly preferred given Caleb's precise, internal voice signature. The Architect must confirm or override this with written justification. The Writer agent will use whatever POV is documented here. This decision must be made before Chapter 1 is drafted and cannot be changed mid-novel.

- [ ] **Step 2: Write Market Notes section**

Comparable titles and extracted patterns:
- *1984* — hook technique (establish the oppressive world through specific sensory detail, not exposition)
- *The Road* — chapter ending pattern (never resolve; always leave a thread dangling)
- *A Canticle for Leibowitz* — emotional beat rhythm (hope and loss in alternation, never one without the other nearby)
- *Klara and the Sun* — voice technique (precise observer narrator whose restraint creates dread)

- [ ] **Step 3: Write Chapter-by-Chapter Beat Map**

For each of the 23 chapters, document:
- Chapter number and working title
- POV character
- Structure point (Hook / Turn 1 / Pinch 1 / Midpoint / Pinch 2 / Turn 2 / Resolution)
- Scene goal (what does Caleb want in this chapter?)
- Conflict (what blocks him?)
- Disaster or partial win (how does it end badly or at cost?)
- Emotional stakes
- Opening hook (first image or action)
- Chapter ending tension (what question is left unresolved?)
- Approximate word count target (~3,000 per chapter)
- Characters present
- Thematic beat active
- Motif instance (if applicable)

Required chapter-level beats from spec:
- Ch. 1: In media res — escort from building; then flashback to anomaly discovery
- Ch. 2: Returns to present; Turn 1 consequences begin
- Ch. 10-12: Midpoint — finds contraband Bible, reads Noah, shifts from vindication to obedience
- Ch. 13-17: Pinch 2 — colony half-built; Theo's recklessness costs three recruits; Sera turns; Sone arrests Caleb
- Ch. 18-20: Turn 2 — PACEM executes; collapse begins; Caleb is heartbroken, not vindicated
- Ch. 21-23: Resolution — colony holds; Caleb releases his maker identity; stillness, not triumph

- [ ] **Step 4: Apply Architect Bestseller Checklist**

Before marking outline complete, verify all items pass:
- [ ] Opening hook in first 200 words of Chapter 1
- [ ] Every chapter ending creates tension (not witty one-liners)
- [ ] Emotional beat every 3-5 scenes across full arc
- [ ] Stakes escalate every 2-3 chapters
- [ ] Character arc has clear turning points documented per chapter
- [ ] World rules are consistent and limited (no omnipotent tech)
- [ ] Themes are shown through action in outline beats, not told through exposition

If any item fails, revise the outline before proceeding.

---

### Task 6: Initialize Memory File

**Files:**
- Create: `novels/the-remnant-protocol/memory.md`

- [ ] **Step 0: Verify memory.md template exists**

```bash
cat memory.md
```
Expected: The root-level `memory.md` template with all required section headers. If not found, do not proceed — the template is required.

Required sections that must be present in the template (and therefore in the novel's memory.md):
- Story Structure
- Character Profiles
- Timeline
- World Rules
- Plot Points
- Thematic Elements
- Chapter Progress Log
- Revision History
- Active Story Questions
- Market Pattern Notes

- [ ] **Step 1: Initialize memory.md from template**

Use `memory.md` template from project root. Populate with all data from the completed foundation files:
- Story structure: Seven-Point, beat map summary
- All five character profiles (summary form with references to character files)
- Timeline: key events mapped to chapter numbers
- World rules: PACEM, technology, society (summary with references to bible.md)
- Plot points: all seven structure points with chapter ranges
- Thematic elements: primary theme, motif, Christian worldview elements
- Chapter progress log: all 23 chapters initialized as PENDING
- Market pattern notes: four comparable titles with extracted patterns

- [ ] **Step 2: Verify memory.md completeness**

All sections from the memory.md template must be populated. Empty sections are not permitted — they indicate the Architect has not completed its work.

- [ ] **Step 3: Architect pre-writing complete — confirm handoff**

Before Writer begins Chapter 1, confirm:
- [ ] All five character files written and complete
- [ ] bible.md written and technology rules verified
- [ ] themes.md written with per-chapter thematic beat map
- [ ] outline.md written with all 23 chapter beats documented
- [ ] memory.md initialized with all foundation data
- [ ] Architect Bestseller Checklist passes (all items green)

**Do not begin Chapter 1 until all items above are confirmed.**

---

## Chunk 2: Act 1 — Chapters 1-9 (Hook Through Pinch 1)

**Goal:** Draft, review, and polish Chapters 1-9. Establish Caleb's world, surface the anomaly, execute the destruction of his credibility, and leave him completely isolated.

**Structure beats covered:** Hook (Ch. 1-2), Turn 1 (Ch. 3-5), Pinch 1 (Ch. 6-9)

**Per-chapter pipeline:** Writer drafts → Dev Editor reviews → (revision loop if needed) → Line Editor polishes → memory.md updated → next chapter begins.

---

### Task 7: Chapter Pipeline — Chapters 1-9

**Files:**
- Create: `novels/the-remnant-protocol/chapters/chapter-01.md` through `chapter-09.md`
- Modify: `novels/the-remnant-protocol/memory.md` (after each chapter)

Repeat the following pipeline for each chapter (01 through 09):

#### Writer Step

- [ ] **Step 1: Read memory.md, outline beat, and relevant character files**

Writer agent reads:
- `memory.md` — current story state, all character data, world rules
- `outline.md` — the specific chapter beat, opening hook, ending tension, scene goal/conflict/disaster
- All `characters/` files for characters who appear in this chapter — read full profiles, not just memory.md summaries. Voice signature must match the character file, not be invented from memory.

- [ ] **Step 2: Apply pre-draft checklist before writing**

Before drafting, confirm:
- [ ] Scene goal is clear (what does Caleb want in this chapter?)
- [ ] Conflict is specific (what blocks him?)
- [ ] Disaster or cost is planned (how does it end badly or at cost?)
- [ ] Opening does NOT begin with waking up, arrival, or weather
- [ ] Chapter ending will leave unresolved tension (not a witty one-liner)
- [ ] Motif instance (if applicable to this chapter) is planned naturally — not forced

- [ ] **Step 3: Draft chapter (~3,000 words)**

Output format (required YAML frontmatter):
```markdown
---
chapter: [number]
title: [chapter title]
pov: caleb-rast
word_count: [count]
timeline_position: [position]
beat_source: [outline.md section reference]
---

[Prose]
```

Craft requirements:
- First 200 words: establish character, setting, tension
- Every scene: Goal → Conflict → Disaster → Sequel structure
- Voice: Caleb's voice is precise, technical, internal — emotion surfaces through what he notices, not what he declares
- Technology: all terms must pass the three-test standard (explainable, grounded, meaningful) — no invented jargon
- "Input chain" motif: only in chapters designated in themes.md — must be natural, never forced
- Dialog: varied with action beats and specific verbs; used to slow pace and develop character
- Exposition: used to accelerate pace and move plot forward
- Christian worldview: woven through choices and consequences — no sermonizing, no tract-like dialogue

**Chapter 1 specific:** Opens in media res (escort from building). Then flashbacks to establish Caleb at career peak and the anomaly discovery. Returns to present at chapter end. The reader must be in the same position as the world: watching a man who looks like he's lost his mind, with no evidence yet that he hasn't.

#### Developmental Editor Step

- [ ] **Step 4: Apply Developmental Editor checklist**

Review the chapter against every item:
- [ ] Plot progression makes logical sense
- [ ] Character motivations are clear and consistent
- [ ] Pacing serves the scene's purpose
- [ ] World-building details align with bible.md rules
- [ ] Sci-fi elements are grounded and internally consistent — all technology passes three-test standard
- [ ] Christian worldview themes present and authentic (no preaching)
- [ ] No theological contradictions or problematic content
- [ ] Scene advances story or develops character (no filler)
- [ ] Seven-Point structure executed with precision for this chapter's beat
- [ ] Character arc transformation tracked correctly vs. outline
- [ ] Stakes escalate appropriately

- [ ] **Step 5: If issues found — return to Writer with specific notes**

Notes must be specific: "The dialog in scene 2 is telling Caleb's emotional state rather than showing it through action" not "show don't tell."

Writer revises and resubmits. Repeat until approved.

- [ ] **Step 6: Dev Editor produces structured output and marks chapter APPROVED**

Dev Editor must write a structured review document saved alongside the chapter (e.g., `chapter-01-dev-review.md`) in this format:

```markdown
## Developmental Review: Chapter [X]

### Structural Assessment
[Analysis of story architecture for this chapter]

### Character Arc Status
[Where each character is in their transformation]

### World-Building Notes
[Consistency and logic check against bible.md]

### Thematic Resonance
[How themes and motif land]

### Bestseller Compliance
[Pattern adherence — hooks, tension, pacing]

### Strengths
- [What works]

### Concerns
- [Any structural/developmental issues]

### Suggestions
- [Specific revision recommendations if needed]

### Status
[Approved / Revise & Resubmit / Major Rewrite Required]
```

Only proceed to Line Editor if Status is **Approved**.

#### Line Editor Step

- [ ] **Step 7: Apply Line Editor checklist**

- [ ] No spelling errors
- [ ] Grammar is correct
- [ ] Punctuation is proper
- [ ] Sentence variety and rhythm feel natural
- [ ] No em dashes or en dashes (unless truly necessary)
- [ ] No witty chapter/section endings
- [ ] Dialog slows pace or develops character/scene
- [ ] Exposition moves pace forward
- [ ] No cursing or obscene language
- [ ] No gratuitous violence or gore
- [ ] No explicit sexual content
- [ ] Christian worldview standards maintained

- [ ] **Step 8: Make corrections and polish**

- [ ] **Step 9: Line Editor produces structured output and marks chapter FINAL**

Line Editor must write a structured review document (e.g., `chapter-01-line-review.md`) in this format:

```markdown
## Line Edit: Chapter [X]

### Corrections Made
- [List significant grammar, spelling, punctuation corrections]

### Style Notes
- [Em dash removals, sentence rhythm adjustments, AI-pattern removals]

### Compliance Status
[Pass / Flagged for Review]

### Final Status
[FINAL / Minor Polish Needed]
```

Line Editor must also update the chapter's YAML frontmatter to add `status: FINAL`.

#### Memory Update Step

- [ ] **Step 10: Update memory.md**

After each FINAL chapter, update:
- Chapter progress log: mark chapter as COMPLETE
- Timeline: add any new events
- Active story questions: add new questions opened; close any resolved
- Character status updates (if applicable)
- Revision history: note any significant changes from outline

- [ ] **Step 11: Save chapter file and confirm**

Confirm `chapter-XX.md` is saved with FINAL status in frontmatter.

---

**Act 1 completion gate — before proceeding to Chunk 3:**
- [ ] All 9 chapters have FINAL status in memory.md
- [ ] No open Dev Editor revision requests
- [ ] Memory.md reflects current story state accurately
- [ ] Pinch 1 ending (Ch. 9) leaves Caleb completely isolated — neural interface flagged, social credit gutted, Sera filed for separation, no one believes him

---

## Chunk 3: Act 2a — Chapters 10-12 (Midpoint)

**Goal:** Draft, review, and polish Chapters 10-12. Caleb stops seeking vindication and starts building. The contraband Bible is the pivot.

**Structure beat covered:** Midpoint

**Critical craft requirement:** The Midpoint is the theological pivot of the entire novel. The Bible passage must land as revelation — not as plot device. The "input chain" motif's second instance appears here. The shift from vindication-seeking to obedience must feel earned, not convenient.

---

### Task 8: Chapter Pipeline — Chapters 10-12

**Files:**
- Create: `novels/the-remnant-protocol/chapters/chapter-10.md` through `chapter-12.md`
- Modify: `novels/the-remnant-protocol/memory.md`

Follow the identical Writer → Dev Editor → Line Editor → memory update pipeline from Task 7.

**Additional Midpoint-specific checks:**

Developmental Editor must verify:
- [ ] The contraband Bible is introduced naturally — its presence is explained by context, not convenience
- [ ] The Noah passage is presented through Caleb's experience, not summarized for the reader
- [ ] The shift from vindication-seeking to obedience is shown through a decision Caleb makes, not stated in narration
- [ ] The "input chain" motif appears in this section naturally — PACEM's outputs with no traceable input chain connects to Caleb's own situation without the connection being spelled out
- [ ] The reader's question ("Is he right or has he broken?") is still alive at the end of Ch. 12 — the Bible does not resolve this question, it deepens it

**Midpoint completion gate:**
- [ ] Chapters 10-12 all FINAL
- [ ] Memory.md updated: Caleb's arc status updated from "seeking vindication" to "building in obedience"
- [ ] Motif log updated: second "input chain" instance recorded with chapter/page reference

---

## Chunk 4: Act 2b — Chapters 13-17 (Pinch 2)

**Goal:** Draft, review, and polish Chapters 13-17. Maximum pressure: colony half-built, agents closing in, Theo's recklessness costs three recruits, Sera turns, Sone arrests Caleb.

**Structure beat covered:** Pinch 2

**This is the novel's most structurally dense section.** Five chapters must carry: Theo's catalyst payoff, Sera's turn, Sone's confrontation, Caleb's arrest, and the colony's near-failure. The Developmental Editor must be especially rigorous here.

---

### Task 9: Chapter Pipeline — Chapters 13-17

**Files:**
- Create: `novels/the-remnant-protocol/chapters/chapter-13.md` through `chapter-17.md`
- Modify: `novels/the-remnant-protocol/memory.md`

Follow the identical pipeline from Task 7.

**Additional Pinch 2-specific checks:**

Developmental Editor must verify:
- [ ] Theo's recklessness follows believably from his guilt — not a plot contrivance
- [ ] The three recruits lost feel like real losses, not anonymous casualties
- [ ] Sera's turn is triggered by something she discovers in her own work — she is not told or convinced; she sees it herself
- [ ] Sera arrives at the colony to work, not to be rescued — this distinction must be clear in the prose
- [ ] Sone's arrest of Caleb is the morally complex scene the spec requires: two men who see the same truth, who made opposite choices, face to face
- [ ] Sone's internal state is visible without being stated — his need for Caleb to be wrong must come through in his behavior
- [ ] Wren's threat classification escalating when Caleb found her must have created compounding pressure — the drone mesh tightening around the colony's location should be a presence in these chapters
- [ ] The "input chain" motif's third instance appears in a colony-building setback scene naturally

- [ ] **Caleb's arrest chapter:** After Sone arrests Caleb, the next scene must show the colony's near-failure without Caleb. Who holds it together? Wren. Her load-bearing presence here sets up her closing line.

**Pinch 2 completion gate:**
- [ ] Chapters 13-17 all FINAL
- [ ] Memory.md updated: Caleb arrested, Sera at colony, Theo's recruits lost, colony status
- [ ] Motif log updated: third "input chain" instance recorded
- [ ] Character status updates: Sera (at colony), Caleb (arrested/held), Sone (filed report)

---

## Chunk 5: Act 3 — Chapters 18-23 (Turn 2 Through Resolution)

**Goal:** Draft, review, and polish Chapters 18-23. PACEM executes. The collapse begins. The colony holds. Caleb releases his maker identity.

**Structure beats covered:** Turn 2 (Ch. 18-20), Resolution (Ch. 21-23)

**Critical craft requirements:**
- Caleb is not vindicated at Turn 2 — he is heartbroken. He never wanted to be right. This must be felt, not stated.
- The resolution ends in stillness, not triumph. No victory lap. No "I told you so." The emotional register is exhausted grace.
- Wren's line ("You didn't build this. You just showed up.") is the novel's thematic landing. It must arrive at the right moment and must not be over-written. The line itself is enough.
- The "input chain" motif's final instance must require no commentary. It lands or it doesn't. If the Writer needs to explain it, the setup in earlier chapters was insufficient — loop back and strengthen those instances.

---

### Task 10: Chapter Pipeline — Chapters 18-23

**Files:**
- Create: `novels/the-remnant-protocol/chapters/chapter-18.md` through `chapter-23.md`
- Modify: `novels/the-remnant-protocol/memory.md`

Follow the identical pipeline from Task 7.

**Additional Act 3-specific checks:**

Developmental Editor must verify:
- [ ] Caleb's release from arrest (or escape, or whatever mechanism) is earned — not convenient
- [ ] The collapse is shown through specific, grounded, technologically-plausible cascade — not vague catastrophe
- [ ] Caleb's emotional response to Turn 2 is grief, not vindication — verify the prose does not let him gloat, even internally
- [ ] The Sone aftermath is handled: does he appear after arresting Caleb? If not, his absence should be felt
- [ ] The resolution's stillness is earned — the reader should feel it as peace after cost, not as a flat ending
- [ ] Wren's line arrives organically — it cannot feel written-for-effect; it must feel like something she would say
- [ ] The "input chain" motif's final instance is in place and does not require authorial explanation
- [ ] The marriage thread with Sera is visible but not resolved — possibility shown, not guaranteed
- [ ] The novel's last image is chosen for resonance, not for closure

**Resolution completion gate:**
- [ ] Chapters 18-23 all FINAL
- [ ] Memory.md: all 23 chapters marked COMPLETE
- [ ] Motif log: all four "input chain" instances recorded — final instance confirmed as requiring no commentary
- [ ] Character arcs confirmed complete:
  - Caleb: releases maker identity — COMPLETE
  - Sera: at colony, faith returning, marriage possible — COMPLETE
  - Theo: redemption earned at cost — COMPLETE
  - Wren: found her reason to hope — COMPLETE
  - Sone: survives, unabsolved — COMPLETE

---

## Chunk 6: Compilation

**Goal:** Compile all 23 FINAL chapters into a single manuscript file. Verify word count, chapter order, and frontmatter consistency.

---

### Task 11: Compile Final Manuscript

**Files:**
- Modify: `novels/the-remnant-protocol/memory.md`
- Create: `output/the-remnant-protocol/manuscript.md`

- [ ] **Step 1: Verify all 23 chapters are FINAL**

Check memory.md chapter progress log. Every chapter must show FINAL status. Any chapter not marked FINAL must complete the full pipeline before proceeding.

- [ ] **Step 2: Verify chapter files exist and are correctly numbered**

```bash
ls novels/the-remnant-protocol/chapters/
```
Expected: `chapter-01.md` through `chapter-23.md` — 23 files, no gaps.

- [ ] **Step 3: Compile into manuscript.md**

Concatenate all chapters in order into `output/the-remnant-protocol/manuscript.md`. Include a title page header:

```markdown
# The Remnant Protocol

*A Novel*

---

[chapters follow in order]
```

- [ ] **Step 4: Verify word count**

Target: ~70,000 words. Acceptable range: 65,000-75,000 words.

```bash
wc -w output/the-remnant-protocol/manuscript.md
```

If significantly under 65,000: flag chapters that are thin for Writer revision.
If significantly over 75,000: flag chapters with pacing issues for Line Editor review.

- [ ] **Step 5: Final manuscript review**

Read the compiled manuscript for:
- [ ] Chapter order is correct (1-23, no gaps, no duplicates)
- [ ] Frontmatter is consistent across all chapters
- [ ] No chapter ends with a witty one-liner
- [ ] Opening of Chapter 1 is the in media res escort scene
- [ ] Closing of Chapter 23 ends in stillness, not triumph
- [ ] Wren's line is present and correctly placed
- [ ] "Input chain" motif appears in four designated instances and nowhere else

- [ ] **Step 6: Update memory.md — project complete**

Final memory.md update:
- Chapter progress log: all 23 COMPLETE
- Project status: MANUSCRIPT COMPLETE
- Final word count recorded
- Completion date recorded

- [ ] **Step 7: Confirm manuscript path**

Final manuscript at: `output/the-remnant-protocol/manuscript.md`

---

## Quality Standards Reference

All agents must enforce these standards throughout every chunk:

### Technology Grounding (Three-Test Standard)
Every technology named must be:
1. **Explainable** — non-technical reader understands from context
2. **Grounded** — extrapolates from real existing technology
3. **Meaningful** — serves story, reveals character, or raises stakes

### Content Standards
- No cursing or obscene language
- No gratuitous violence or gore
- No explicit sexual content
- Tasteful mentions only when absolutely necessary for character or scene development

### AI-Pattern Avoidance
- No em dashes or en dashes (unless truly necessary)
- No tessellation, symphony, tapestry metaphors
- No excessive adverbs
- No abstract observations without sensory grounding
- Sentence variety: mix short, medium, long, fragments

### Motif Discipline
The "input chain" motif appears in exactly four instances (Ch. 1-2, Ch. 10-12, Ch. 16-17, Ch. 21-23). It is never explained to the reader. It must arrive as felt recognition.

### Christian Worldview
Shown through character choices, consequences, and arc. Never exposition. Never dialogue-sermons. Never preaching at the reader.
