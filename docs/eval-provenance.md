# Eval Provenance Policy

This repository publishes reviewed Tessl-native eval scenarios from `tessl-evals/`.

Generated scenarios from third-party services or private workflows must stay out of tracked paths. Store them locally in ignored directories such as `private-evals/` when needed for private validation.

Root `evals/` is generated Tessl staging output only. Do not commit files under `evals/`; the release workflow stages `tessl-evals/` into `evals/` immediately before publishing.

Tracked custom-evaluator examples belong in `personal-evals/`. They are open examples for the custom full-context evaluator, which loads `SKILL.md` plus companion resources as XML. They do not need to be Tessl-compatible while Tessl only consumes `SKILL.md`.

Tracked Tessl-native scenarios belong in `tessl-evals/`. They must target only publishable skills from `tile.json`; repo-local `workflows/` are intentionally excluded because they are not part of the Tessl tile.

Public eval examples must meet one of these criteria:

- They are authored specifically for this repository and released under the repository license.
- They are derived from a permissively licensed source, with attribution and license notes included beside the example.

Do not rename generated scenarios to make them look original. Provenance must describe where the scenario came from and why it can be redistributed.
