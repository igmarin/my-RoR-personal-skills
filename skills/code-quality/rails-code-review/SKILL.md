---
name: rails-code-review
license: MIT
description: >
  Reviews Rails pull requests, focusing on controller/model conventions,
  migration safety, query performance, and Rails Way compliance. Covers
  routing, ActiveRecord, security, caching, and background jobs. Use when
  reviewing existing Rails code for quality, conducting a PR review, or
  doing a code review on Ruby on Rails (RoR) code.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Rails Code Review (The Rails Way)

When **reviewing** Rails code, analyze it against the following areas. When **writing** new code, follow **rails-code-conventions** and **rails-stack-conventions**.

**Core principle:** Review early, review often. Self-review before PR. Re-review after significant changes.

## HARD-GATE: After implementation (before PR)

```text
After green tests + linters pass + YARD + doc updates:
1. Self-review the full branch diff using the Review Order below.
2. Fix Critical items; resolve or ticket Suggestion items.
3. Only then open the PR.
generate-tasks must include a "Code review before merge" task.
```

## Quick Reference

| Area | Key Checks |
|------|------------|
| Routing | RESTful, shallow nesting, named routes |
| Controllers | Skinny, strong params, scoped `before_action` |
| Models | Structure order, enums, scopes, `inverse_of` |
| Queries | N+1 prevention, `exists?`, `find_each` batches |
| Migrations | Reversible, concurrent indexes on large tables |
| Security | Strong params, no `html_safe` on user input |
| Jobs | Idempotent, retriable, appropriate backend |

## Review Order

Work through the diff in this sequence. Detailed criteria: [REVIEW_CHECKLIST.md](./REVIEW_CHECKLIST.md).

Configuration → Routing → Controllers → Views → Models → Associations → Queries → Migrations → Validations → I18n → Sessions → Security → Caching → Jobs → Tests

**Edge case handling:**
- **Empty diff**: State "No code changes to review" and stop.
- **Large diff (>50 files)**: Prioritize **Critical** checks first; sample key files for **Suggestion** items.
- **Single file**: Apply all relevant review areas to that file.
- **Test-only changes**: Focus on test quality and organization.

## Severity Levels

Use **only** these labels:

- **`Critical`** — security, data loss, crash, or **Always Critical** (see below). Block merge.
- **`Suggestion`** — conventions, performance, or "Thin controller -> fat model" anti-patterns.
- **`Nice to have`** — small style or micro-optimization.

### Always Critical (flag every occurrence):
- `params.require(...).permit!` — privilege escalation
- `html_safe` or `raw` on user-supplied content — XSS
- **Business logic inside a controller action** — pricing, tax, or domain calculation
- Unparameterized / string-interpolated SQL — injection
- Destructive migration without a safe path on large tables

## Output Style

Group findings by severity. See [assets/examples.md](./assets/examples.md) for JSON/PR comment shapes.

```text
## Review — <PR title or area>

### Critical
- [path/to/file.rb:LINE] (Area) One-line risk. **Mitigation:** concrete next step.

### Suggestion
- [path/to/file.rb:LINE] (Area) ... **Mitigation:** ...

**Actions required:** <one line per severity level found — e.g. Critical -> block merge>
```

**Tag (Area) from:** Controllers, Routing, Views, Models, Queries, Migrations, Validations, Security, Caching, Jobs, Tests. Cover **≥4** distinct areas if applicable.

## Re-review Criteria

Re-diff the branch after:
1. **Any** Critical fix (mandatory).
2. **>3** Suggestion fixes or any architecture change.
3. Changes affecting queries, auth, or migrations.

## Integration

| Skill | When to chain |
|-------|---------------|
| **rails-review-response** | When receiving feedback and deciding implementation |
| **rails-architecture-review** | When review reveals structural problems |
| **rails-migration-safety** | When reviewing migrations on large tables |

## Assets
- [assets/checklist.md](assets/checklist.md)
- [assets/examples.md](assets/examples.md)
