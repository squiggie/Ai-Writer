#!/usr/bin/env python3
# =============================================================================
# update-library.py — Update library.json and regenerate the site index page
#
# Usage: update-library.py <novel_dir> <book_slug> <date>
# Example: update-library.py /path/to/novels/book-2026-03-22 book-2026-03-22 2026-03-22
# =============================================================================
import json
import os
import re
import sys
from pathlib import Path
from datetime import datetime

# ── Args ──────────────────────────────────────────────────────────────────
if len(sys.argv) < 4:
    print("Usage: update-library.py <novel_dir> <book_slug> <date>", file=sys.stderr)
    sys.exit(1)

NOVEL_DIR  = Path(sys.argv[1])
BOOK_SLUG  = sys.argv[2]
DATE_STR   = sys.argv[3]
AIWRITER   = Path(os.environ.get("AIWRITER_DIR", "/storage/backup/landen/source/aiwriter"))
SITE_DIR   = Path(os.environ.get("SITE_DIR", AIWRITER / "site"))
LIBRARY_JSON = SITE_DIR / "library.json"

# ── Read idea.md metadata ─────────────────────────────────────────────────
def parse_frontmatter(filepath):
    """Parse YAML-style frontmatter from a markdown file."""
    meta = {}
    in_front = False
    try:
        with open(filepath) as f:
            for line in f:
                line = line.rstrip()
                if line == "---":
                    if not in_front:
                        in_front = True
                        continue
                    else:
                        break
                if in_front and ":" in line:
                    key, _, val = line.partition(":")
                    meta[key.strip()] = val.strip()
    except FileNotFoundError:
        pass
    return meta

def extract_premise(filepath):
    """Extract text under ## Premise heading."""
    try:
        with open(filepath) as f:
            content = f.read()
        match = re.search(r"## Premise\n+(.+?)(?=\n## |\Z)", content, re.DOTALL)
        if match:
            return match.group(1).strip().replace("\n", " ")
    except FileNotFoundError:
        pass
    return ""

def count_final_chapters(novel_dir):
    chapters_dir = novel_dir / "chapters"
    if not chapters_dir.exists():
        return 0
    count = 0
    for f in chapters_dir.glob("chapter-[0-9][0-9].md"):
        try:
            with open(f) as fh:
                if "status: FINAL" in fh.read():
                    count += 1
        except Exception:
            pass
    return count

# ── Build entry ───────────────────────────────────────────────────────────
idea_file = NOVEL_DIR / "idea.md"
meta = parse_frontmatter(idea_file)
premise = extract_premise(idea_file)
chapter_count = count_final_chapters(NOVEL_DIR)

entry = {
    "slug":           BOOK_SLUG,
    "title":          meta.get("title", BOOK_SLUG),
    "date":           DATE_STR,
    "genre":          meta.get("genre", ""),
    "pov":            meta.get("pov", ""),
    "tone":           meta.get("tone", ""),
    "setting_type":   meta.get("setting_type", ""),
    "comp_authors":   meta.get("comp_authors", ""),
    "premise":        premise[:300] + ("..." if len(premise) > 300 else ""),
    "chapters_total": chapter_count,
    "url":            f"books/{BOOK_SLUG}/",
}

# ── Load or create library.json ───────────────────────────────────────────
SITE_DIR.mkdir(parents=True, exist_ok=True)
if LIBRARY_JSON.exists():
    with open(LIBRARY_JSON) as f:
        library = json.load(f)
else:
    library = {"books": [], "last_updated": ""}

# Update existing entry or append new one
updated = False
for i, book in enumerate(library["books"]):
    if book["slug"] == BOOK_SLUG:
        library["books"][i] = entry
        updated = True
        break
if not updated:
    library["books"].insert(0, entry)

library["last_updated"] = DATE_STR
library["total_books"] = len(library["books"])

with open(LIBRARY_JSON, "w") as f:
    json.dump(library, f, indent=2)
print(f"[update-library] library.json updated ({len(library['books'])} books)")

# ── Regenerate index.html ─────────────────────────────────────────────────
def render_book_card(book):
    title       = book.get("title", book["slug"])
    date        = book.get("date", "")
    genre       = book.get("genre", "")
    tone        = book.get("tone", "")
    premise     = book.get("premise", "")
    url         = book.get("url", f"books/{book['slug']}/")
    comp        = book.get("comp_authors", "")
    ch_total    = book.get("chapters_total", 0)

    comp_html = f'<p class="comp">In the tradition of {comp}</p>' if comp else ""
    meta_line = " · ".join(filter(None, [genre, tone]))

    return f"""    <article class="book-card">
      <div class="book-meta">{meta_line}</div>
      <h2><a href="{url}">{title}</a></h2>
      {comp_html}
      <p class="premise">{premise}</p>
      <div class="book-footer">
        <span class="date">{date}</span>
        <span class="chapters">{ch_total} chapters</span>
        <a class="read-btn" href="{url}">Read &rarr;</a>
      </div>
    </article>"""

cards_html = "\n".join(render_book_card(b) for b in library["books"])
total      = library["total_books"]
updated_dt = datetime.strptime(DATE_STR, "%Y-%m-%d").strftime("%B %d, %Y")

index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>The Daily Novel — Library</title>
  <style>
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    :root {{
      --bg:      #0f0f0f;
      --surface: #181818;
      --border:  #2a2a2a;
      --text:    #e0e0e0;
      --muted:   #888;
      --accent:  #c89b5e;
    }}
    body {{
      background: var(--bg);
      color: var(--text);
      font-family: Georgia, "Times New Roman", serif;
      line-height: 1.7;
      padding: 2rem 1rem;
    }}
    header {{
      max-width: 860px;
      margin: 0 auto 3rem;
      border-bottom: 1px solid var(--border);
      padding-bottom: 1.5rem;
    }}
    header h1 {{ font-size: 2rem; color: var(--accent); letter-spacing: 0.02em; }}
    header p  {{ color: var(--muted); margin-top: 0.4rem; font-size: 0.95rem; }}
    .library  {{
      max-width: 860px;
      margin: 0 auto;
      display: grid;
      gap: 1.5rem;
    }}
    .book-card {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 1.5rem;
    }}
    .book-meta {{ color: var(--muted); font-size: 0.8rem; text-transform: uppercase;
                  letter-spacing: 0.08em; margin-bottom: 0.5rem; font-family: sans-serif; }}
    .book-card h2 {{ font-size: 1.3rem; margin-bottom: 0.4rem; }}
    .book-card h2 a {{ color: var(--text); text-decoration: none; }}
    .book-card h2 a:hover {{ color: var(--accent); }}
    .comp    {{ color: var(--muted); font-size: 0.88rem; margin-bottom: 0.75rem;
                font-style: italic; }}
    .premise {{ font-size: 0.95rem; color: #bbb; margin-bottom: 1rem; }}
    .book-footer {{
      display: flex; align-items: center; gap: 1rem;
      font-size: 0.82rem; font-family: sans-serif;
    }}
    .date, .chapters {{ color: var(--muted); }}
    .read-btn {{
      margin-left: auto;
      color: var(--accent);
      text-decoration: none;
      font-weight: bold;
      font-size: 0.9rem;
    }}
    .read-btn:hover {{ text-decoration: underline; }}
    footer {{
      max-width: 860px;
      margin: 3rem auto 0;
      border-top: 1px solid var(--border);
      padding-top: 1rem;
      color: var(--muted);
      font-size: 0.8rem;
      font-family: sans-serif;
    }}
  </style>
</head>
<body>
  <header>
    <h1>The Daily Novel</h1>
    <p>{total} novel{'' if total == 1 else 's'} · Last updated {updated_dt}</p>
  </header>
  <main class="library">
{cards_html}
  </main>
  <footer>
    <p>A new novel every day. Christian worldview. Literary fiction.</p>
  </footer>
</body>
</html>
"""

index_path = SITE_DIR / "index.html"
with open(index_path, "w") as f:
    f.write(index_html)

print(f"[update-library] index.html written ({total} book cards)")
