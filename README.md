# 📖 Project Anino

Welcome to the team! This document outlines our development workflow, our 8-person team structure, and repository guidelines. Please read through this before picking up your first issue.

---

## 🚀 Quick Start (Godot + Git LFS)

We use **Git Large File Storage (LFS)** for visual novel assets (e.g. PNG, PSD, WAV, OGG). **You must initialize LFS locally** or you may end up with pointer files instead of real assets.

### Requirements

- **Godot 4.6 (recommended)**
  - This project declares `config/features` including `"4.6"` in `project.godot`.
- **Git** and **Git LFS**

### 1) Clone + Git LFS (mandatory)

```bash
# Enable Git LFS once per machine
git lfs install

# Clone the repo
git clone <your-repo-url>
cd <your-repo-name>

# Fetch LFS objects
git lfs pull

# Optional sanity checks
git lfs env
git lfs ls-files
```

### 2) Open the project in Godot

1. Open **Godot Project Manager**
2. Click **Import** and select `project.godot`
3. Click **Import & Edit**
4. Press **F5** to run

### 3) Test framework (GUT) setup

This repository includes **GUT** under `res://addons/gut/` and it is enabled in `project.godot`.

1. Open **Project → Project Settings → Plugins**
2. Ensure **GUT** is enabled
3. Confirm tests exist under `res://test/`

---

## 🧭 Project Rules (Read before touching files)

### 1) Naming + layout (CI is case-sensitive)

- Use **`snake_case`** and **lowercase** for **all file/folder names**
- Keep folders **segregated by concern**; don’t create “misc” buckets
  - Example pattern: `assets/ui/map/...` instead of mixing map files into generic `assets/ui/`

Code style:

- GDScript files: `snake_case.gd`
- Classes: `PascalCase`
- Variables/functions: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE`
- Scene files: `snake_case.tscn`
- Node names: `PascalCase`
- Signals: `snake_case`

### 2) Source vs Godot-native

- **Source assets (LFS)** → `res://assets/`
  - `.png`, `.jpg`, `.psd`, `.wav`, `.ogg`
- **Godot-native data** → `res://resources/`
  - `.tres`, `.res`, themes

### 3) Asset organization directive (no messy roots)

- Organize assets by **category first** (what it is), then by **concern/usage** (where/how it’s used)
- Prefer **concern foldering even for reusable assets** (no generic `shared/` bucket)
- If an asset is scene-specific, add a scene folder under the concern (when possible)

Example (matches current repo categories):

```text
assets/
└── background/
    └── chapter_1/
        └── scene_1/
            ├── rooftop_sunset.jpg
            └── rooftop_night.jpg
```

---

## 📦 SOP: Before You Push

### A) Always (code or assets)

1. Naming/layout rules followed (especially case + `snake_case`)
2. Open Godot and ensure the project runs (F5)
3. Run all GUT tests (see below)

### B) If you changed assets in `res://assets/`

1. Confirm LFS is active:

```bash
git lfs install
```

2. Open the project once in Godot to generate/update imports
3. Verify LFS + avoid pointer files:

```bash
git lfs pull

git lfs status

git lfs ls-files

# Pointer files are small text files starting with:
# "version https://git-lfs.github.com/spec/v1"
head -n 5 assets/path/to/suspicious_file
```

4. Import artifacts policy (required for CI):

- Commit all `*.import` sidecar files.
- Commit the `.import/` directory **if it is generated/present** in the repo.

### C) If you moved/renamed anything

1. Ensure references were updated in `.tscn` / `.tres`
2. Re-run GUT tests

---

## ✅ Automated Tests (GUT)

### Run locally (mandatory before PR)

1. Enable the plugin: **Project Settings → Plugins → GUT → On**
2. Open the GUT UI (from the GUT panel)
3. Run all tests in `res://test/`

---

## 🧪 When CI / Automated Tests Fail (PR Protocol)

### 1) How to read CI logs

1. Open the failed workflow in **GitHub → Actions** for your PR
2. Click the failed run, then open the failing job/step
3. Search within logs for:

- `ERROR:`
- `SCRIPT ERROR:`
- `Parse Error:`
- `Failed loading resource`
- `Could not open`

### 2) Common failure causes (fix these first)

- **Case / naming mismatch**: works locally, fails on Linux CI
- **Missing/stale imports**: `.import/` or `*.import` not committed after new/moved assets
- **Broken paths after moves**: `.tscn` / `.tres` still pointing to old locations
- **LFS pointer committed**: asset file is actually a small text pointer

---

## 🔄 Development Workflow

### Branching & commits

- Branches: `type/issue-id-short-description`
  - Example: `feature/101-dialogue-skipping`
- Conventional Commits:

```text
feat(scope): description
fix(scope): description
chore(scope): description
docs(scope): description
```

### Pull Requests

- Open a PR against `main`
- Link the issue (e.g., `Closes #101`)
- Ensure the issue has labels: `type:*`, `size:*`, `priority:*`
- Request a review from the Architect
- **Squash and Merge** once approved and CI checks pass

---

## 🛑 The Golden Rule: "One Dev, One Scene"

Godot scene files (`.tscn`) are difficult to merge. To avoid corrupted files and merge conflicts:

- Communicate if you are editing a shared scene
- Componentize large scenes into smaller instanced scenes

---

## 👥 Team Structure

- **Project Manager**: Owns the GitHub Board, requirements, and sprint prioritization
- **Architect / Tech Lead**: Defines core architecture and acts as the primary PR reviewer
- **DevOps**: Manages CI/CD, Godot export templates, and automated builds
- **Gameplay Programmers**: Implement mechanics, AI, and core game loops
- **UI & Systems Programmers**: Build menus, save systems, and audio implementation

---

## 📁 Project Architecture

```text
res://
├── assets/               # LFS-backed binaries (png/jpg/psd/wav/ogg)
├── builds/               # Export outputs (web/windows)
├── resources/            # Godot-native resources (.tres/.res)
├── scenes/               # .tscn (UI/system/templates)
├── src/                  # GDScript (autoload/gameplay/ui)
├── story/                # Narrative data (JSON/text/markdown)
└── addons/               # Editor plugins (GUT, etc.)
```
