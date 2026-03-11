---
name: generate-tasks
description: Generate a detailed, step-by-step task list in Markdown from a PRD or feature requirements. Use when the user asks to create tasks, generate a task list, break down a PRD into tasks, plan implementation steps, or create an implementation checklist.
---

# Generating a Task List from Requirements

## Goal

Create a step-by-step task list in Markdown that guides a developer (especially a junior) through implementing a feature. Tasks should be actionable, ordered, and tied to the requirements.

## When to Use

- User asks for tasks, task list, implementation checklist, or to "break down" a feature.
- User points to an existing PRD and wants implementation steps.
- **Input:** A PRD file, a feature description, or a link to requirements. If a PRD exists, derive tasks from its **Functional Requirements** and **Goals** first.

## Process

1. **Receive requirements:** User provides a feature description, task request, or path to a PRD (e.g. `tasks/prd-[feature-name].md`).
2. **Analyze:** If a PRD is given, extract Functional Requirements and Goals. Otherwise use the feature description. Identify scope and main work areas.
3. **Choose flow:**
   - **Default (with pause):** Generate only parent tasks (~5 high-level tasks). Present them and say: "I've generated the high-level tasks. Reply **Go** to generate sub-tasks, or tell me what to change."
   - **One shot:** If the user said "todo junto", "all at once", "sin pausa", "no pause", "generate everything", or similar, generate parent tasks and sub-tasks in a single pass and save the full file. Do not wait for "Go".
4. **Parent tasks:** Always include **0.0 Create feature branch** as the first task unless the user asks otherwise. Aim for ~5 parent tasks (e.g. setup, backend, frontend, tests, docs/deploy).
5. **Sub-tasks:** For each parent, break down into small, concrete steps. One sub-task = one clear action. Order so that dependencies are respected.
6. **Relevant Files:** List files that will likely be created or modified (including tests). Refine this list when generating sub-tasks. Infer test command from the project when possible (e.g. Gemfile → `bundle exec rspec`, package.json scripts → `npm test` or `npx jest`).
7. **Save:** Save as `tasks-[feature-name].md` in `/tasks/`. Use the same `[feature-name]` as the PRD if one was provided.

## Output Format

The task list must follow this structure. If the source was a PRD, add a "Based on" line at the top.

```markdown
# Task List: [Feature Name]

Based on: `prd-[feature-name].md` *(only if PRD was the source)*

## Relevant Files

- `path/to/file1.ext` - Why this file is relevant.
- `path/to/file1.spec.ext` (or `.test.ext`) - Tests for file1.
- `path/to/file2.ext` - Why this file is relevant.

### Notes

- Tests live next to or mirror the code they cover.
- Run tests: `bundle exec rspec` *(replace with project's test command)*

## Instructions for Completing Tasks

Check off each task when done: change `- [ ]` to `- [x]`. Update the file after each sub-task, not only after a full parent task.

## Tasks

- [ ] 0.0 Create feature branch
  - [ ] 0.1 Create and checkout branch (e.g. `git checkout -b feature/[feature-name]`)
- [ ] 1.0 [Parent task title]
  - [ ] 1.1 [Concrete sub-task]
  - [ ] 1.2 [Concrete sub-task]
- [ ] 2.0 [Parent task title]
  - [ ] 2.1 [Concrete sub-task]
```

## Interaction Model

- **With pause:** After showing parent tasks, wait for "Go" (or user corrections) before generating and saving the full list with sub-tasks.
- **Without pause:** If the user requested everything in one go, generate and save the complete task list immediately.

## Target Audience

Write for a **junior developer**: each sub-task should be a single, clear action they can complete and check off without ambiguity.
