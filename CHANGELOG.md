# Changelog

All notable changes to this repository will be documented in this file.

This project uses semantic versioning for published skill-library releases.

## [5.0.0] - Unreleased

### Added

- Added required `metadata.json` files for all current `personal-evals` scenarios.
- Added metadata validation to `scripts/validate-evals.sh`, including target skill/workflow resolution.
- Added `personal-evals/schema.json` as the metadata contract for custom evaluator scenarios.
- Added XML context bundle generation with `scripts/eval_context_builder.rb`.
- Added test coverage for XML context generation.
- Added `plans/personal-evals-and-custom-evaluator.md` to preserve the custom evaluator plan.

### Changed

- Clarified that `personal-evals/` is the tracked source for open custom evaluator examples.
- Clarified that root `evals/` is generated Tessl staging output and must not be committed.
- Updated eval documentation to describe `skill_bundle_xml` context: `SKILL.md` plus companion resources.
- Updated CodeQL configuration to ignore intentionally messy `personal-evals/**` fixture code.

### Removed

- Removed committed root `evals/` scenarios by moving them into `personal-evals/`.

### Validation

- `rtk bash scripts/validate-evals.sh`
- `ruby scripts/test/eval_context_builder_test.rb`
- `rtk bash scripts/validate-plugins.sh`
- `cd mcp_server && rtk bundle exec rake test`
