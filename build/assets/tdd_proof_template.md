# TDD Proof Template

Use this template when reporting a planned code change.

```markdown
## Tests-first evidence

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

For search-related tasks only, include the SearchService regression checklist from `SKILL.md`.
