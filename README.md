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

## 👥 Team Structure

- **Project Manager**: Owns the GitHub Board, requirements, and sprint prioritization
- **Architect / Tech Lead**: Defines core architecture and acts as the primary PR reviewer
- **DevOps**: Manages CI/CD, Godot export templates, and automated builds
- **Gameplay Programmers**: Implement mechanics, AI, and core game loops
- **UI & Systems Programmers**: Build menus, save systems, and audio implementation

---

## 🛑 The Golden Rule: "One Dev, One Scene"

Godot scene files (`.tscn`) are difficult to merge. To avoid corrupted files and merge conflicts:

- **Communicate**: If you are editing a major shared scene (e.g., `Main.tscn`), tell the team
- **Componentize**: Break large scenes into smaller, instanced `.tscn` files
- **Test Locally**: Always run the game and your specific GUT tests before pushing code

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

Example (per-concern foldering, like `assets/ui/map/...`):

```text
assets/
└── ui/
	├── map/
	│   ├── background_map.png
	│   ├── chapter_1_button.png
	│   └── chapter_2_button.png
	└── loading/
		└── load_spinner.png
```

---

## 🔄 Development Workflow

### 1) Branching & Commits

- Create a branch for every issue:
  - `type/issue-id-description` (e.g., `docs/23-update-quick-start-and-setup-guide`)
- We use **Conventional Commits**:

```text
feat(scope): description
fix(scope): description
chore(scope): description
docs(scope): description
```

### 2) Pull Requests

- Open a PR against `main`
- Link the issue (e.g., `Closes #23`)
- Ensure the issue has proper labels:
  - `type:*`
  - `size:*`
  - `priority:*`
- Request a review from the Architect
- **Squash and Merge** once approved and CI checks pass

---

## 📄 PR Template Requirement

All pull requests must follow `.github/pull_request_template.md`.

**Related Issue**

```text
Closes #
```

**Type of Change** *(must match issue label)*

- `feat`: New feature (`type: feature`)
- `fix`: Bug fix (`type: bug`)
- `chore`: Tooling/refactor (`type: chore`)
- `docs`: Documentation (`type: docs`)

**Testing & Checklist**

- My commit messages follow the Conventional Commits format
- I have tested my changes in Godot
- I have run GUT tests locally before pushing
- I have updated documentation if needed
- I have not broken any existing functionality

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

## 🧷 Git LFS Push Failures (GH008) — What it means and how to fix it

If you see this during `git push`:

- `remote: error: GH008: Your push referenced at least 1 unknown Git LFS object`

It means your commit references an LFS object that **was not uploaded** to GitHub’s LFS storage yet.

### Hooks note (this repo uses Husky)

This repo uses Husky (`core.hooksPath=.husky/_`). The LFS pre-push hook lives at:

- `.husky/_/pre-push`

So you won’t see it under `.git/hooks/pre-push`.

### Fix steps

```bash
# Ensure the LFS hook is correctly installed/updated (safe to run)
git lfs update --force

# Upload all LFS objects required by your branch
git lfs push --all origin <your-branch>

# Retry the normal push
git push -u origin <your-branch>
```

### If it says your local objects are missing/corrupt

Repair your local LFS cache, then retry:

```bash
git lfs fetch --all origin
git lfs fsck
git lfs checkout
```

---

## 📅 Weekly Development Timeline

- **Sunday — Task Assignment & Kickoff**
  - Stand-up meeting to distribute tasks; work can start immediately after
- **Wednesday — Progress Review (Project Manager)**
  - Review progress and unblock issues
- **Friday — Build Review (Technical Lead)**
  - Evaluate the current build and request improvements
- **Saturday & Sunday — DevOps Review & Evaluation**
  - Integration checks, testing, and deployment readiness evaluation

---

## 📁 Project Architecture

```text
res://
├── assets/               # LFS-backed binaries (png/jpg/psd/wav/ogg)
├── resources/            # Godot-native resources (.tres/.res)
├── scenes/               # .tscn (ui/system/templates)
├── src/                  # GDScript (autoload/gameplay/ui)
├── story/                # Narrative data (JSON/text/markdown)
├── addons/               # Editor plugins (GUT, etc.)
└── builds/               # Export outputs (web/windows) (not committed)
```

---

## 📂 res://assets/ (Managed via Git LFS)

**Primary Owner:** DevOps
**Contributors:** Art & Sound Teams

**Role:** Ensures `.gitattributes` tracks large files so the repo stays lean.

- `characters/` *(DevOps / Art)*: high-resolution character sprites
- `background/` *(DevOps / Art)*: large environment files
- `music/` + `sfx/` *(DevOps / Sound)*: `.ogg` and `.wav`

---

## 📂 res://scenes/ (The "Assembly Line")

**Primary Owner:** UI & Systems Programmers & Gameplay Programmer

- `ui/` *(UI & Systems Programmers)*: menus and HUD `.tscn`
- `system/` *(Gameplay Programmer)*: invisible scenes (audio/save/transition)
- `templates/` *(Game Designer / Gameplay Programmer)*: chapter templates

---

## 📂 res://src/ (The "Engine Room")

**Primary Owner:** Gameplay Programmer

- `ui/` *(UI & Systems Programmers)*: menu logic scripts
- `gameplay/` *(Gameplay Programmer)*: core systems (e.g., dialogue)
- `autoload/` *(DevOps / Gameplay Programmer)*: global singletons

---

## 📂 res://story/ & res://resources/ (The "Database")

**Primary Owner:** Gameplay Programmer

- `story/`: dialogue, branching logic, narrative data (JSON/text)
- `resources/`: `.tres` bridges referencing assets (e.g., characters, themes)

---

## 📊 Ownership & Tech Stack

| Folder        | Primary Dev              | Tech Stack                |
| ------------- | ------------------------ | ------------------------- |
| `assets/`     | DevOps                   | Git LFS, `.png`, `.ogg`   |
| `scenes/ui/`  | UI & Systems Programmers | Godot Nodes, `.tscn`      |
| `src/ui/`     | UI & Systems Programmers | GDScript (UI logic)       |
| `src/gameplay/` | Gameplay Programmer    | GDScript (system logic)   |
| `src/autoload/` | Gameplay Programmer    | Singletons / global state |
| `story/`      | Gameplay Programmer      | JSON / Text / Markdown    |

---

## 🏷️ Label Legend

Every issue should have one label from each of the first three categories.

### 1) Type (What is it?)

- `type: bug` – Something is broken
- `type: feature` – New mechanics or content
- `type: chore` – Tooling or refactoring
- `type: docs` – Documentation updates

### 2) Size (How long?)

- `size: S` – 1–2 hours
- `size: M` – 1–3 days
- `size: L` – Full sprint

### 3) Priority (When?)

- `priority: high` – Critical blockers or must-haves
- `priority: med` – Standard sprint work
- `priority: low` – Polish and minor tweaks

### 4) Status (Where is it?)

- `status: in-progress` – Active development
- `status: blocked` – Technical or tool-related hard stop
- `status: needs-info` – Waiting on a decision, art asset, or PM
- `status: in-review` – Finished; waiting for Architect approval
- `status: revision` – Changes requested by reviewer; high priority
