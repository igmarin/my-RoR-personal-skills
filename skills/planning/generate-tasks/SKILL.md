---
name: generate-tasks
license: MIT
description: >
  Use when breaking down a feature or generating an implementation task list from a PRD.
  Output MUST follow this exact structure: (1) Task 0.0: Create feature branch with git
  checkout command, (2) Relevant Files section listing all files with concrete paths,
  (3) At least 3 TDD task groups with four sub-tasks each: X.Xa Write spec, X.Xb Run spec
  and verify it FAILS, X.Xc Implement, X.Xd Run spec and verify it PASSES, (4) YARD
  documentation task, (5) Documentation update task for README/diagrams, (6) Code review
  gate, (7) Save as tasks-[name].md in /tasks/ folder. Trigger words: task list,
  implementation plan, feature breakdown, todo list, project tasks, work plan, break
  down this PRD, generate tasks, feature branch, TDD, write spec, run spec fail, run
  spec pass.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Generating a Task List from Requirements

## Quick Reference

- **Task 0.0:** Always "Create feature branch".
- **Tasks format:** Each sub-task must be single action (2-5 mins).
- **Paths:** Use exact file paths (`app/models/user.rb`).
- **TDD:** Write spec -> Run fail -> Implement -> Run pass.

## HARD-GATE

```text
DO NOT skip Task 0.0 (Create feature branch) unless the user explicitly overrides.
DO NOT use vague references instead of exact file paths.
DO NOT summarize the task list in a table instead of producing the actual checklist artifact.
DO NOT combine the TDD quadruplet sub-tasks into a single task. They must be broken out:
  a) Write spec
  b) Run spec (verify fails)
  c) Implement
  d) Run spec (verify passes)
Each c-step is one implementation action in one primary file. Split route,
controller, view, model, migration, service, and concern work into separate
quadruplets or separate follow-up tasks.
```

## Core Process

1. **Analyze:** Extract Functional Requirements and Goals from the PRD, or use the feature description. Identify scope and main work areas.
2. **Detect work type:** Rails monolith, engine, API-only, background job, or external integration — affects spec paths and follow-up skills.
   - For new endpoint or controller behavior, order the first TDD group around the request spec before model/service persistence slices.
3. **Determine Output Mode:** 
   - If the user asks for strategy, sequencing, phases, or approach, produce a phased plan first.
   - If the user asks for implementation tasks, checklist, or exact steps, produce the detailed mode.
4. **Draft Relevant Files Section:** List all files to create or modify including tests, docs, and diagrams. Infer test command (`bundle exec rspec` or `npm test`).
5. **Draft Tasks:** Construct the sequential task list incorporating at least 3 TDD task groups (write spec, run fail, implement, run pass), followed by YARD, documentation updates, and a code review gate. Each TDD implementation sub-task line must name the exact file path (e.g., `spec/...`, `app/...`, `config/...`); documentation and review tasks should include relevant paths where applicable.
6. **Save:** Save the output as `tasks-[feature-name].md` in `/tasks/`. Use the same `[feature-name]` as the PRD if one was provided.
7. **Verify Checkpoint:** Re-read the saved file and confirm all required elements from the Output Style are present.
8. **Final Artifact:** Include the full checklist content in the final answer or `answer.md`; do not only describe that the checklist was created.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific guidance is required:

- **[HEURISTICS.md](./HEURISTICS.md)** — Use when deciding the first spec to write for a given change type (endpoint, service, job, engine, bug fix).
- **[TASK_TEMPLATES.md](./TASK_TEMPLATES.md)** — Use when you need the full template structure for phased plans or detailed checklists.

## Output Style

When asked to generate tasks, your output MUST include:

0. **Full checklist artifact** — Include the concrete `tasks-[feature-name].md` content, not a summary table about the file.
1. **Task 0.0** — "Create feature branch" with checkout command (e.g., `git checkout -b feature/name`).
2. **Relevant Files section** — All files to create/modify with concrete paths, listed before Tasks.
3. **TDD quadruplets** — At least 3 implementation groups with four sub-tasks each:
   - `X.Xa` Write spec for `[behavior]` at `spec/...`
   - `X.Xb` Run `bundle exec rspec spec/...` — verify it **fails**
   - `X.Xc` Implement `[behavior]` at `app/...`
   - `X.Xd` Run `bundle exec rspec spec/...` — verify it **passes**
   Every `a/b/c/d` line must include the concrete file path or command path for that slice.
4. **YARD parent task** — Add YARD docs to new/changed public API; name each file.
5. **Documentation update task** — Update README, diagrams (Mermaid, ADRs), domain docs; list concrete paths.
6. **Code review gate** — Self-review; fix blockers before opening PR.
7. **Save location** — State that it was saved to `tasks-[feature-name].md` in `/tasks/` folder.
8. **Guidance Used** — Add a section with this exact heading. State whether `HEURISTICS.md` and/or `TASK_TEMPLATES.md` were used, and why.
9. **Instructions for Completing Tasks** — Add a section with this exact heading. Tell the implementer to work one sub-task at a time, verify RED before implementation and GREEN after, and avoid combining actions.
10. **Language** — Must be in English unless explicitly requested otherwise.

For endpoint work, the first TDD quadruplet should normally be the request spec slice. Add model or service slices after the request boundary is established unless the PRD is explicitly persistence-only.

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-prd** | Generate PRD first, then derive tasks from it |
| **plan-tests** | When planning the best first failing spec for a Rails change |
| **plan-tickets** | When the same initiative also needs ticket drafts |
| **triage-bug** | When the request starts from a bug report |
