# 📖 Project Anino

Welcome to the team! This document outlines our development workflow, our 8-person team structure, and repository guidelines. Please read through this before picking up your first issue.

---

## 🚀 Quick-Start & Setup

We use **Git Large File Storage (LFS)** for all visual novel assets (PNG, PSD, WAV, OGG). You must have LFS installed to pull the art and audio correctly.

### 1. Installation

Ensure you have **Godot 4.x** and **Git LFS** installed.

```bash
# Initialize Git LFS on your machine (only needs to be done once)
git lfs install

# Clone the repository
git clone <your-repo-url>
cd <your-repo-name>

# Explicitly pull the large files
git lfs pull
```

### 2. Running the Game

1. Open the Godot Project Manager
2. Click **Import** and select the `project.godot` file
3. Click **Import & Edit**
4. Press **F5** to run the project

---

## 👥 Team Structure

* **Project Manager**: Owns the GitHub Board, requirements, and sprint prioritization
* **Architect / Tech Lead**: Defines core architecture and acts as the primary PR reviewer
* **DevOps**: Manages CI/CD, Godot export templates, and automated builds
* **Gameplay Programmers**: Implement mechanics, AI, and core game loops
* **UI & Systems Programmers**: Build menus, save systems, and audio implementation

---

## 🛑 The Golden Rule: "One Dev, One Scene"

Godot scene files (`.tscn`) are difficult to merge. To avoid corrupted files and merge conflicts:

* **Communicate**: If you are editing a major shared scene (e.g., `Main.tscn`), tell the team
* **Componentize**: Break large scenes into smaller, instanced `.tscn` files
* **Test Locally**: Always run the game and your specific GUT tests before pushing code

---

## 🔄 Development Workflow

### 1. Branching & Commits

* Create a branch for every issue:
  `type/issue-id-description`
  *(e.g., `feature/101-player-dash`)*

* We use **Conventional Commits**. PRs will be blocked if titles do not match:

```text
feat(scope): description
fix(scope): description
chore(scope): description
```

---

### 2. Pull Requests

* Open a PR against `main`
* Link the issue (e.g., `Closes #101`)
* Request a review from the Architect
* **Squash and Merge** once approved and CI checks pass

---

## 📁 Project Architecture

```text
res://
├── assets/         # LFS tracked: art/backgrounds, art/characters, audio/bgm, audio/sfx
├── data/           # Story scripts and JSON data
├── scenes/         # Game levels and main scenes
├── scripts/        # Global scripts and core logic
└── ui/             # Menus and dialogue boxes
```

---

## 🏷️ Label Legend

Every issue should have one label from each of the first three categories.

### 1. Type (What is it?)

* `type: bug` – Something is broken
* `type: feature` – New mechanics or content
* `type: chore` – Tooling or refactoring
* `type: docs` – Documentation updates

---

### 2. Size (How long?)

* `size: S` – 1–2 hours
* `size: M` – 1–3 days
* `size: L` – Full sprint

---

### 3. Priority (When?)

* `priority: high` – Critical blockers or must-haves
* `priority: med` – Standard sprint work
* `priority: low` – Polish and minor tweaks

---

### 4. Status (Where is it?)

* `status: in-progress` – Active development
* `status: blocked` – Technical or tool-related hard stop
* `status: needs-info` – Waiting on a decision, art asset, or PM
* `status: in-review` – Finished; waiting for Architect approval
* `status: revision` – Changes requested by reviewer; high priority

---
