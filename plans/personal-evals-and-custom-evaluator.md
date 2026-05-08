# Personal Evals and Custom Evaluator Plan

## Goal

Build a custom validation path for this skill repository that can evaluate skills and workflows with the full context agents actually receive: the target `SKILL.md` plus companion resources serialized as XML.

Root `evals/` is reserved for temporary Tessl staging output only. The canonical authoring space for open examples is `personal-evals/`.

## Decisions Locked

- `personal-evals/` is tracked and contains open example scenarios for the custom evaluator.
- Root `evals/` is generated only when intentionally staging scenarios for Tessl.
- Root `evals/` must not contain committed files because Tessl treats it as a repo-local eval override.
- The custom evaluator uses `skill_bundle_xml` context.
- Context is discovered by filesystem convention first, not manually listed per scenario.
- Tessl compatibility is an adapter concern. Personal evals do not need to be Tessl-compatible while Tessl consumes only `SKILL.md`.

## Completed

- Moved previously tracked root eval scenarios into `personal-evals/`.
- Ignored root `evals/` as generated Tessl staging output.
- Added `scripts/eval_context_builder.rb` to build XML from a skill or workflow `SKILL.md` plus companion resources.
- Added unit coverage for the XML context builder.
- Added `scripts/validate-evals.sh`.
- Added `personal-evals/schema.json`.
- Updated `personal-evals/README.md`, `docs/eval-provenance.md`, and `docs/evaluator-and-agents-roadmap.md` to document the new ownership model.
- Added required `metadata.json` files for every current `personal-evals` scenario.
- Updated eval validation so each scenario requires `task.md`, `criteria.json`, and `metadata.json`.
- Updated eval validation to confirm each metadata target resolves to a real skill or workflow `SKILL.md`.

## Current Validation Commands

```bash
rtk bash scripts/validate-evals.sh
ruby scripts/test/eval_context_builder_test.rb
rtk bash scripts/validate-plugins.sh
cd mcp_server && rtk bundle exec rake test
```

## Next Steps

1. Add a stable evaluator context entrypoint.
   - Suggested command: `bin/eval-context personal-evals/workflow-rails-tdd-loop`
   - Reads `metadata.json`.
   - Resolves `target_type` and `target_name`.
   - Builds XML through `scripts/eval_context_builder.rb`.
   - Prints XML to stdout.
   - Fails clearly when metadata, target files, or eval ownership rules are invalid.

2. Add tests for the entrypoint.
   - Skill scenario resolves to `skills/<category>/<target_name>/SKILL.md`.
   - Workflow scenario resolves to `workflows/<target_name>/SKILL.md`.
   - Missing target fails with a clear message.
   - Root `evals/**` tracked files fail before context generation.

3. Add a custom evaluator runner.
   - Suggested command: `bin/eval-run personal-evals/workflow-rails-tdd-loop`.
   - Uses `bin/eval-context` as the context source.
   - Runs baseline and with-context modes.
   - Writes run output to an ignored results path.

4. Replace `personal-evals/benchmarks.json`.
   - Treat the current file as stale historical output.
   - Prefer ignored run logs such as `personal-evals/results/*.jsonl`.
   - Commit curated benchmark snapshots only when they are intentionally reviewed.

5. Add optional Tessl export tooling.
   - Suggested command: `bin/eval-export-tessl personal-evals/<scenario>`.
   - Exports only scenarios whose metadata explicitly allows Tessl export.
   - Writes generated files into root `evals/`.
   - Never commits generated `evals/` output.

## Open Questions

- Should custom evaluator results be JSONL, SQLite, or both?
- Should `benchmarks.json` be removed now or preserved until the first runner exists?
- Should `bin/eval-context` live in `bin/`, `scripts/`, or a future Ruby gem/CLI namespace?
