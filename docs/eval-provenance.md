# Eval Provenance Policy

This repository does not publish generated eval scenarios.

Generated scenarios from third-party services or private workflows must stay out of tracked paths. Store them locally in ignored directories such as `private-evals/` when needed for private validation.

Public eval examples must meet one of these criteria:

- They are authored specifically for this repository and released under the repository license.
- They are derived from a permissively licensed source, with attribution and license notes included beside the example.

Do not rename generated scenarios to make them look original. Provenance must describe where the scenario came from and why it can be redistributed.
