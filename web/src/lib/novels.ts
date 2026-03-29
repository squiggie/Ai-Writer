import type { CollectionEntry } from 'astro:content'
import { existsSync } from 'node:fs'

type NovelEntry = CollectionEntry<'novels'>
type ChapterEntry = CollectionEntry<'chapters'>

const COVER_EXTENSIONS = ['png', 'jpg', 'jpeg', 'webp', 'avif']

export function sourceBookKey(
  entry: { id: string; data?: { source_slug?: string; slug?: string } },
) {
  if (entry.data?.source_slug?.trim()) {
    return entry.data.source_slug.trim()
  }

  if (entry.id.includes('/')) {
    return entry.id.split('/')[0]!
  }

  return entry.data?.slug?.trim() || entry.id
}

export function routeSlugForNovel(novel: NovelEntry) {
  return novel.data.slug?.trim() || sourceBookKey(novel)
}

export function coverUrlForNovel(novel: NovelEntry) {
  if (novel.data.cover?.trim()) {
    return novel.data.cover.trim()
  }

  const routeSlug = routeSlugForNovel(novel)

  for (const extension of COVER_EXTENSIONS) {
    const publicCoverPath = new URL(`../../public/covers/${routeSlug}.${extension}`, import.meta.url)
    if (existsSync(publicCoverPath)) {
      return `/covers/${routeSlug}.${extension}`
    }
  }

  return null
}

export function chaptersForNovel(novel: NovelEntry, chapters: ChapterEntry[]) {
  const key = sourceBookKey(novel)
  return chapters
    .filter((chapter) => sourceBookKey(chapter) === key)
    .sort((a, b) => a.data.chapter - b.data.chapter)
}

export function totalWordsForChapters(chapters: ChapterEntry[]) {
  return chapters.reduce((sum, chapter) => sum + (chapter.data.word_count ?? 0), 0)
}

function datedBookTimestamp(novel: NovelEntry) {
  const match = sourceBookKey(novel).match(/^book-(\d{4}-\d{2}-\d{2})$/)
  if (!match) {
    return null
  }

  const timestamp = Date.parse(`${match[1]}T00:00:00Z`)
  return Number.isNaN(timestamp) ? null : timestamp
}

export function compareNovelsNewestFirst(a: NovelEntry, b: NovelEntry) {
  const aDate = datedBookTimestamp(a)
  const bDate = datedBookTimestamp(b)

  if (aDate !== null && bDate !== null && aDate !== bDate) {
    return bDate - aDate
  }

  if (aDate !== null && bDate === null) {
    return -1
  }

  if (aDate === null && bDate !== null) {
    return 1
  }

  return routeSlugForNovel(a).localeCompare(routeSlugForNovel(b))
}
