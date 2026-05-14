# TDD Proof Template

Use this template when reporting a planned code change.

```markdown
## Tests-first evidence

- Read phase: `[task source]`, `[focused spec path]`, `[implementation file path]`, `[related regression paths considered]`
- Spec file: `spec/...`
- First command: `bundle exec rspec spec/...`
- Expected RED reason: `[missing method / missing route / failing behavior]`
- Confirmed this is not a setup, factory, syntax, or dependency error.

## GREEN checkpoint

- Focused rerun: `bundle exec rspec spec/...`
- Result: PASS
- Broader check: `bundle exec rspec` or the strongest available project check
- Manual check: `[curl / Rails console / log inspection / browser check]`
```

Always include the SearchService regression checklist section from `SKILL.md`; mark it not applicable when the task does not touch search behavior.
