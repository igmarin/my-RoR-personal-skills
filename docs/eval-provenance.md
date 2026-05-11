# Eval Provenance Policy

This repository uses two public eval source areas and one generated staging area.

| Path | Purpose | Commit policy |
|------|---------|---------------|
| `tessl-evals/` | Tessl-native scenarios for publishable skills in `tile.json`. | Tracked. |
| `personal-evals/` | Open examples for the upcoming `ruby-skill-bench` full-context evaluator. | Tracked. |
| `evals/` | Generated Tessl staging output produced from `tessl-evals/`. | Ignored; do not commit. |

Tessl currently validates skills, not repository workflows. Tessl-native scenarios must target only publishable skills from `tile.json`.

`ruby-skill-bench` is planned as a Ruby gem for validating skills and workflows with full context. Its `personal-evals/` examples load `SKILL.md` plus companion resources as XML. They do not need to be Tessl-compatible while Tessl only consumes `SKILL.md`.

Generated scenarios from third-party services or private workflows must stay out of tracked paths. Store them locally in ignored directories such as `private-evals/` when needed for private validation.

Root `evals/` is generated Tessl staging output only. The release workflow stages `tessl-evals/` into `evals/` immediately before publishing.

Public eval examples must meet one of these criteria:

- They are authored specifically for this repository and released under the repository license.
- They are derived from a permissively licensed source, with attribution and license notes included beside the example.

Do not rename generated scenarios to make them look original. Provenance must describe where the scenario came from and why it can be redistributed.
