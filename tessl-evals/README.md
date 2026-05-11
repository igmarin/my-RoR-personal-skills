# Tessl Eval Source

This directory contains tracked, Tessl-native eval scenario source for the publishable skills in `tile.json`.

Root `evals/` is generated staging output and stays ignored. Before publishing, run:

```bash
ruby scripts/stage-tessl-evals.rb
```

The staging script flattens each tracked `tessl-evals/<skill>/scenario-0/` directory into `evals/<skill>/` because Tessl expects every direct child of `evals/` to be a runnable scenario with `task.md`, `criteria.json`, and `capability.txt`.

Validate coverage and scenario shape with:

```bash
ruby scripts/validate-tessl-evals.rb
```

Regenerate the current baseline scenarios from `tile.json` with:

```bash
ruby scripts/generate-tessl-evals.rb
```

Do not add `workflows/**` scenarios here. The repository workflows are intentionally excluded from the Tessl tile.
