# keyes-timothy.github.io

Personal website of Timothy Keyes — built with [Quarto](https://quarto.org/) and R, deployed to GitHub Pages via CI/CD.

**Live site:** [https://keyes-timothy.github.io](https://keyes-timothy.github.io)

---

## Project Structure

```
keyes-timothy.github.io/
├── _quarto.yml              # Site configuration (navbar, theme, metadata)
├── index.qmd                # Landing page (bio paragraph + interactive visNetwork graph)
├── bio.qmd                  # Full multi-paragraph bio
├── cv.qmd                   # CV (programmatic from CSVs)
├── publications.qmd         # Publications (tabbed by topic, from CSV)
├── research.qmd             # Research overview
├── talks.qmd                # Talks
├── blog.qmd                 # Blog listing page
├── styles.css               # Custom CSS for all pages
├── data/                    # Data files read by R during rendering
│   ├── about.md             # (Legacy) about text
│   ├── publications.csv     # All publications with topic/preferred columns
│   ├── cv_education.csv     # Education entries (degree, institution, status)
│   ├── cv_experience.csv    # Work experience (title, org, status)
│   ├── cv_awards.csv        # Awards & honors (award, org, year, details)
│   └── cv_media.csv         # Media/press mentions (year, type, outlet, title, link)
├── files/
│   ├── profile.jpg          # Profile photo (sidebar)
│   └── papers/              # PDF copies of publications
├── images/
│   └── profile.png          # Profile photo (landing page)
├── posts/                   # Blog posts (one .qmd per post)
│   └── 2026-01-06-welcome.qmd
├── .github/workflows/
│   └── quarto-publish.yml   # CI/CD: renders site and deploys to gh-pages
├── .gitignore
└── README.md                # This file (not rendered to the site)
```

---

## How Rendering Works

### Quarto site rendering

Running `quarto render` builds all `.qmd` files into HTML in `_site/`. The site config in `_quarto.yml` defines:
- **Navbar order:** Bio → CV → Publications → Research → Talks → Blog
- **Theme:** cosmo (light) / darkly (dark) with dark/light toggle
- **CSS:** academicons CDN + custom `styles.css`

### Pages and their data dependencies

| Page | Source file | Data files used | R packages |
|------|-----------|----------------|------------|
| **Landing** | `index.qmd` | None (graph is hardcoded in R) | `visNetwork`, `tibble`, `dplyr` |
| **Bio** | `bio.qmd` | None (plain markdown) | — |
| **CV** | `cv.qmd` | `cv_education.csv`, `cv_experience.csv`, `publications.csv`, `cv_awards.csv`, `cv_media.csv` | `readr`, `dplyr`, `tidyr`, `stringr`, `purrr`, `glue` |
| **Publications** | `publications.qmd` | `publications.csv` | `readr`, `dplyr`, `tidyr`, `stringr`, `purrr`, `glue`, `htmltools` |
| **Research** | `research.qmd` | None | — |
| **Talks** | `talks.qmd` | None | — |
| **Blog** | `blog.qmd` + `posts/*.qmd` | None | — |

### Landing page graph (visNetwork)

The interactive force-directed network on `index.qmd` is built with `visNetwork`. Key design:
- **Nodes** are defined in a `tribble()` with `name` and `group` columns
- **Edges** are defined in a separate `tribble()` with `from`/`to` columns
- **4 hub nodes** (Clinical AI, Single-Cell Biology, Open Source, Medical Education) are larger and always show labels
- **Leaf node labels** are hidden by default and revealed on hover via custom JavaScript in `visEvents()`
- **Physics** is always on (springy drag behavior)
- **Colors** use a Stanford-inspired palette defined in `group_colors`
- Hub nodes only connect to non-hub leaf nodes; cross-cluster connections are mediated by leaf nodes (e.g., Bioinformatics bridges Single-Cell Biology to ML and Tidy Data)

### CV page rendering

`cv.qmd` reads 5 CSV files and renders each section programmatically:
- **Education/Experience:** `render_entry()` function produces timeline-style HTML divs with colored left borders. Uses `status` column (Current/Former/Conferred/Expected) instead of year ranges.
- **Selected Publications:** Filters `publications.csv` to `preferred == TRUE`, applies co-authorship markers (†/‡), bolds "Timothy Keyes", and links titles.
- **Awards:** Sorted reverse-chronologically. Clickable `<details>` elements for awards with descriptions.
- **Media:** Linked titles with outlet/year metadata.

### Publications page rendering

`publications.qmd` reads `publications.csv` and renders cards in a tabbed layout:
- **Tabs:** All | Clinical AI | Single-Cell Biology | Medical Education (with Bootstrap icons)
- **Cards** include: linked title, author list with co-authorship markers, journal/year, PDF/Link/Cite buttons, expandable abstract
- **Topic assignment** is stored in the `topic` column of the CSV

---

## Data Files Reference

### `data/publications.csv`

| Column | Description |
|--------|-------------|
| `year` | Publication year |
| `authors` | Comma-separated author list |
| `journal` | Journal name |
| `title` | Paper title |
| `abstract` | Abstract text (optional) |
| `citation` | Formatted citation string for copy-to-clipboard |
| `link` | URL to the paper |
| `file_name` | PDF filename in `files/papers/` (optional) |
| `preferred` | `TRUE` if shown in CV's "Selected Publications" |
| `author_position` | `first`, `co_first`, `co_second`, or `middle` |
| `co_author_count` | Number of co-first/co-second authors |
| `co_author_start` | 1-based index of first co-author in the author list |
| `topic` | `Clinical AI`, `Single-Cell Biology`, or `Medical Education` |

### `data/cv_education.csv`

| Column | Description |
|--------|-------------|
| `degree` | Degree name |
| `institution` | School name |
| `location` | City, State |
| `status` | `Current`, `Conferred`, `Expected 2028`, or `Completed` |
| `details` | Semicolon-separated details (rendered as line breaks) |

### `data/cv_experience.csv`

| Column | Description |
|--------|-------------|
| `title` | Job title |
| `organization` | Employer |
| `location` | City, State |
| `status` | `Current` or `Former` |
| `details` | Semicolon-separated details |

### `data/cv_awards.csv`

| Column | Description |
|--------|-------------|
| `award` | Award name |
| `organization` | Granting organization |
| `year` | Year(s) awarded |
| `details` | Description (optional; renders as expandable) |

### `data/cv_media.csv`

| Column | Description |
|--------|-------------|
| `year` | Year |
| `type` | Media type (e.g., "Feature", "Interview") |
| `outlet` | Publication/outlet name |
| `title` | Article title |
| `link` | URL |

---

## CI/CD Deployment

### How it works

1. Push to `main` triggers `.github/workflows/quarto-publish.yml`
2. GitHub Action installs Quarto, R, and R packages
3. Runs `quarto render` to build the site into `_site/`
4. Pushes `_site/` contents to the `gh-pages` branch
5. GitHub Pages serves the `gh-pages` branch at `https://keyes-timothy.github.io`

### Required GitHub settings

- **Settings → Pages → Source:** Deploy from branch `gh-pages` / `/ (root)`

### R packages installed by CI

`readr`, `dplyr`, `tidyr`, `stringr`, `purrr`, `glue`, `htmltools`, `stringi`, `visNetwork`

---

## Local Development

```bash
# Render entire site
quarto render

# Open locally
open _site/index.html

# Live preview with auto-reload (recommended)
quarto preview

# Render single page
quarto render index.qmd
```

---

## Common Tasks

### Add a new publication
1. Add a row to `data/publications.csv`
2. Set `topic` to one of: `Clinical AI`, `Single-Cell Biology`, `Medical Education`
3. Set `preferred = TRUE` if it should appear in the CV's Selected Publications
4. Optionally add a PDF to `files/papers/` and set `file_name`
5. Commit and push

### Add a new blog post
1. Create `posts/YYYY-MM-DD-title.qmd` with YAML frontmatter
2. Commit and push

### Update the network graph
Edit the `nodes` and `edges` tribbles in `index.qmd`. The graph auto-renders from the data.

### Update CV entries
Edit the relevant CSV in `data/` (`cv_education.csv`, `cv_experience.csv`, `cv_awards.csv`, `cv_media.csv`).