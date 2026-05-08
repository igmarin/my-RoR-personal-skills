# Personal Evals and Custom Evaluator Plan (Refined)

## Goal

Build a custom validation path for this skill repository that can evaluate skills and workflows with the full context agents actually receive: the target `SKILL.md` plus companion resources serialized as XML.

Root `evals/` is reserved for temporary Tessl staging output only. The canonical authoring space for high-fidelity examples is `personal-evals/`.

## Decisions Locked (Refined)

- **Ownership:** `personal-evals/` contains high-fidelity scenarios. Root `evals/` is an ignored staging area.
- **Context Format:** Use `skill_bundle_xml` for rich context (SKILL.md + assets + examples).
- **Execution:** Delegate core LLM logic to the external `rails-agent-eval` gem.
- **Results Persistence:** Hybrid model using **JSONL** for execution logs (traceability) and **SQLite** (ignored) for benchmark analysis and comparison.
- **Interface:** All user-facing commands live in `bin/`.
- **Tessl Integration:** `bin/eval-export-tessl` performs a "clean and rebuild" of the `evals/` directory.

## Completed

- Moved previously tracked root eval scenarios into `personal-evals/`.
- Ignored root `evals/` as generated Tessl staging output.
- Added `scripts/eval_context_builder.rb` for XML serialization.
- Added `personal-evals/schema.json` and `metadata.json` requirements.
- Updated eval validation to ensure targets resolve to real `SKILL.md` files.

## Next Steps

### 1. Standardize Command Interface (bin/)
- **`bin/eval-context <scenario-path>`**
    - Resolves target (skill/workflow) via `metadata.json`.
    - Outputs XML bundle to stdout.
- **`bin/eval-run <scenario-path>`**
    - Wrapper for `rails-agent-eval`.
    - Prepares context via `bin/eval-context`.
    - Appends results to `personal-evals/results/runs.jsonl`.
    - Syncs run data to a local `benchmarks.sqlite` (ignored).
- **`bin/eval-export-tessl <scenario-path>`**
    - Cleans target staging directory in `evals/`.
    - Rebuilds Tessl-compatible version (SKILL.md only) for enabled scenarios.

### 2. Result Analysis Layer
- Implement a simple Ruby service to upsert JSONL results into the SQLite database.
- Allow querying benchmarks by model, date, or skill name.

### 3. Cleanup & Hygiene
- Delete stale `personal-evals/benchmarks.json` (Old names/data).
- Update `scripts/validate-evals.sh` to check `bin/` executable integrity.

## Execution Architecture

1. **rails-agent-skills (this repo):** Source of Truth for Skills, Scenarios, and XML context preparation.
2. **rails-agent-eval (gem):** Execution engine for LLM interaction, judging, and config management.
