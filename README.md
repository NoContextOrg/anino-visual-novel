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

Here’s the final cleaned version with the **Label Legend section removed**:

---

## 🔄 Development Workflow

### 1. Branching & Commits

* Create a branch for every issue:
  `type/issue-id-description`
  *(e.g., `feature/101-player-dash`)*

* We use **Conventional Commits**, with the following allowed types:

```text id="58214"
feat(scope): description
fix(scope): description
chore(scope): description
docs(scope): description
```

---

### 2. Pull Requests

* Open a PR against `main`
* Link the issue (e.g., `Closes #101`)
* Ensure the issue has proper labels:

  * `type:*`
  * `size:*`
  * `priority:*`
* Request a review from the Architect
* **Squash and Merge** once approved and CI checks pass

---

### 📄 PR Template Requirement

All pull requests must follow `.github/pull_request_template.md`:

#### **Related Issue**

```id="x91kd3"
Closes #
```

#### **Type of Change** *(must match issue label)*

* feat: New feature (`type: feature`)
* fix: Bug fix (`type: bug`)
* chore: Tooling/refactor (`type: chore`)
* docs: Documentation (`type: docs`)

---

### **Testing & Checklist**

* My commit messages follow the Conventional Commits format
* I have tested my changes in Godot
* I have updated documentation if needed
* I have not broken any existing functionality

---

## 📅 Weekly Development Timeline

### **Sunday — Task Assignment & Kickoff**

A stand-up meeting is conducted to distribute and explain tasks for the week.
Team members may begin working on their assigned responsibilities immediately after the meeting.

---

### **Wednesday — Progress Review (Project Manager)**

The Project Manager reviews task progress, identifies any blockers or risks, and provides guidance or adjustments as needed.

---

### **Friday — Build Review (Technical Lead)**

The Technical Lead evaluates the current build, assesses completed features, and provides technical feedback and required improvements.

---

### **Saturday & Sunday — DevOps Review & Evaluation**

The DevOps team reviews system integration, conducts testing, and evaluates deployment readiness and performance.

---

## 📁 Project Architecture

```text id="9f4a21"
res://
├── assets/
│   ├── characters/       # Subfolders for each NPC (sprites, expressions)
│   ├── backgrounds/      # Organized by location
│   ├── music/
│   └── sfx/
├── scenes/
│   ├── ui/               # Main Menu, Dialogue Box, Settings (UI Team)
│   ├── system/           # Save/Load, Scene Manager, Audio Manager
│   └── templates/        # Master scene for a "Chapter"
├── src/                  # The GDScript logic
│   ├── ui/               # Scripts for UI components
│   ├── gameplay/         # Dialogue parser, Choice handlers
│   └── autoload/         # Globals (GameManager.gd, EventBus.gd)
├── story/
│   ├── chapter_1/        # JSON/Resource/Dialogue files
│   ├── chapter_2/
│   └── ...
└── resources/            # Custom .tres files (Character profiles, Theme files)
```

---

## 📂 res://assets/ (Managed via Git LFS)

**Primary Owner:** DevOps
**Contributors:** Art & Sound Teams

**Role:** Ensures `.gitattributes` tracks large files so the repo stays lean.

* **characters/** *(DevOps / Art)*
  High-resolution character sprites. DevOps manages LFS locking to prevent conflicts on `.psd` or `.png` files.

* **backgrounds/** *(DevOps / Art)*
  Large environment files, organized by `location_time` (e.g., `rooftop_sunset.png`).

* **music/** & **sfx/** *(DevOps / Sound)*
  All `.ogg` and `.wav` files. DevOps monitors LFS bandwidth for efficient access.

---

## 📂 res://scenes/ (The "Assembly Line")

**Primary Owner:** UI & Systems Programmers & Gameplay Programmer

* **ui/** *(UI & Systems Programmers)*
  `.tscn` files for HUD, Settings, and Save/Load screens.

* **system/** *(Gameplay Programmer)*
  “Invisible” scenes like `AudioPlayer`, `SaveEngine`, and `TransitionFader`.

* **templates/** *(Game Designer / Gameplay Programmer)*
  Master story scene combining Background + Character + Dialogue UI.

---

## 📂 res://src/ (The "Engine Room")

**Primary Owner:** Gameplay Programmer

* **ui/** *(UI & Systems Programmers)*
  Menu logic (e.g., `MainMenu.gd` handles button signals).

* **gameplay/** *(Gameplay Programmer)*
  Core systems. `DialogueParser.gd` is critical for the Alpha build.

* **autoload/** *(DevOps / Gameplay Programmer)*
  Globals like `GameState.gd`. These singletons must be stable and well-documented.

---

## 📂 res://story/ & res://resources/ (The "Database")

**Primary Owner:** Gameplay Programmer 

* **chapter_1/** to **chapter_5/**
  Dialogue, branching logic, and narrative data (JSON/text). Not LFS-tracked for fast iteration.

* **story role:**
  Defines narrative flow, choices, pacing, and structure used by the gameplay systems.

* **resources/**
  `.tres` files acting as bridges (e.g., `Character.tres` referencing assets in `assets/characters/`).

---

## 📊 Ownership & Tech Stack

| Folder        | Primary Dev                         | Tech Stack                |
| ------------- | ----------------------------------- | ------------------------- |
| assets/       | DevOps                              | Git LFS, `.png`, `.ogg`   |
| scenes/ui/    | UI & Systems Programmers            | Godot Nodes, `.tscn`      |
| src/ui/       | UI & Systems Programmers            | GDScript (Visual Logic)   |
| src/gameplay/ | Gameplay Programmer                 | GDScript (System Logic)   |
| src/autoload/ | Gameplay Programmer                 | Singletons / Global State |
| story/        | Gameplay Programmer                 | JSON / Text / Markdown    |

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
