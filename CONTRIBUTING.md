# Contributing to Anino Visual Novel

This document complements `README.md` and defines contribution rules for code, assets, and pull requests.

## Requirements

- **Godot 4.6 (recommended)** (project declares `config/features` including `"4.6"`)
- **Git** + **Git LFS** (mandatory)

## Setup (Git LFS + project)

```bash
# Enable LFS once per machine
git lfs install

# Clone + fetch LFS objects
git clone https://github.com/NoContextOrg/anino-visual-novel.git
cd anino-visual-novel

git lfs pull
```

Open `project.godot` in Godot and run the project (F5).

## Naming and folder rules (CI is case-sensitive)

- Use **`snake_case`** and **lowercase** for all file/folder names
- Keep folders **segregated by concern** (avoid dumping unrelated files in a root)

Code conventions:

- GDScript files: `snake_case.gd`
- Classes: `PascalCase`
- Variables/functions: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE`
- Scene files: `snake_case.tscn`
- Node names: `PascalCase`
- Signals: `snake_case`

## Source vs Godot-native

- **Assets (LFS-backed)**: `res://assets/` (`.png`, `.jpg`, `.psd`, `.wav`, `.ogg`)
- **Godot-native resources**: `res://resources/` (`.tres`, `.res`)

### Asset organization (no messy roots)

- Category first, then concern/usage (scene/feature/system)
- Prefer concern foldering even for reusable assets (no generic `shared/` bucket)
- If scene-specific, add `scene_*` under the concern when possible

## Testing (mandatory before PR)

This repo includes GUT in `res://addons/gut/`.

1. Ensure the plugin is enabled: **Project → Project Settings → Plugins → GUT → On**
2. Run all tests under `res://test/`

## SOP: Before you push

1. Follow naming/layout rules (case + `snake_case`)
2. Run the project (F5)
3. Run all GUT tests

If you changed assets in `res://assets/`:

- Open the project to generate/update imports
- Commit `*.import` sidecar files
- Commit `.import/` **if it is generated/present** in the repo

LFS sanity checks:

```bash
git lfs pull
git lfs status
git lfs ls-files
```

## CI failures

- Read logs in **GitHub → Actions** and search for `ERROR:`, `SCRIPT ERROR:`, `Parse Error:`
- Common causes: case mismatches, missing/stale imports, broken paths after moves, committed LFS pointer files

## Pull requests

- Branch: `type/issue-id-description` (example: `docs/23-update-quick-start-and-setup-guide`)
- Conventional Commits: `feat|fix|chore|docs(scope): description`
- Follow `.github/pull_request_template.md`
- Link issues in PR description: `Closes #<id>`
- Ensure labels: `type:*`, `size:*`, `priority:*`
