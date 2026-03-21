import { defineCollection, z } from 'astro:content'
import { glob } from 'astro/loaders'

// One entry per novel — reads novels/<slug>/idea.md
const novels = defineCollection({
  loader: glob({ pattern: '*/idea.md', base: '../../novels' }),
  schema: z.object({
    title: z.string(),
    slug: z.string(),
    genre: z.string(),
    pov: z.string(),
    tone: z.string(),
    setting_type: z.string().optional(),
    comp_authors: z.string().optional(),
  }),
})

// One entry per finished chapter — reads novels/<slug>/chapters/chapter-NN.md
// Draft and review files (chapter-NN-draft.md, chapter-NN-dev-review.md) are
// excluded by the pattern: only chapter-NN.md (exactly two digits) matches.
const chapters = defineCollection({
  loader: glob({ pattern: '*/chapters/chapter-[0-9][0-9].md', base: '../../novels' }),
  schema: z.object({
    chapter: z.number(),
    title: z.string(),
    pov: z.string().optional(),
    word_count: z.number().optional(),
    timeline_position: z.string().optional(),
    beat_source: z.string().optional(),
    status: z.string().optional(),
    continuity_flag: z.string().optional(),
  }),
})

export const collections = { novels, chapters }
