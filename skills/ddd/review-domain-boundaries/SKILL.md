---
name: review-domain-boundaries
license: MIT
description: >
  Use when reviewing a Ruby on Rails app for Domain-Driven Design boundaries,
  bounded contexts, language leakage, cross-context orchestration, or unclear
  ownership. Identifies misplaced domain models, detects cross-context coupling,
  names ownership conflicts, and recommends the smallest credible boundary
  improvement. Covers context mapping and leakage detection.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Review Domain Boundaries

## Quick Reference

| Area | What to check |
|------|---------------|
| Bounded contexts | Distinct language, rules, and ownership |
| Context leakage | One area reaching across another's concepts casually |
| Shared models | Same object name used with conflicting meanings |
| Orchestration | Use cases coordinating multiple contexts without a clear owner |
| Ownership | Who owns invariants, transitions, and side effects |

## HARD-GATE

```text
DO NOT recommend splitting code into new contexts unless the business boundary is explicit enough to name.
DO NOT treat every large module as a bounded context automatically.
ALWAYS identify the leaked language or ownership conflict before proposing structural changes.
```

## Core Process

Use this skill when the main problem is not syntax or style, but unclear domain boundaries.

**Core principle:** Fix context leakage before adding more patterns.

### When to Use

- The repo appears to mix multiple business concepts under one model or service namespace.
- Teams are debating ownership, boundaries, or where a rule belongs.
- A Rails architecture review reveals cross-domain coupling.
- **Next step:** Chain to `model-domain` when a context is clear enough to model tactically, or to `refactor-code` when boundaries need incremental extraction.

### Review Order

1. **Map entry points:** Start from controllers, jobs, services, APIs, and UI flows that expose business behavior.
2. **Name the contexts:** Group flows and rules by business capability, not by current folder names alone.
3. **Find leakage:** Look for terms, validations, workflows, or side effects crossing context boundaries.
4. **Check ownership:** Decide which context should own invariants, transitions, and external side effects.
5. **Propose the smallest credible improvement:** Rename, extract, isolate, or wrap before attempting large reorganizations.

### Detecting Leakage

Use ripgrep to find cross-context references before reading code manually:

```bash
# Find references from one context into another
rg 'Billing.*Fleet|Fleet.*Billing' app/

# Find cross-namespace constant usage
rg 'Billing::[A-Z]' app/services/fleet/
rg 'Fleet::[A-Z]' app/services/billing/

# Find callbacks that touch foreign concepts
rg 'after_(create|update|save).*Job|after_(create|update|save).*Mailer' app/models/
```

### Common Pitfalls

- Treating a shared database table as proof of a shared context — storage and domain boundaries are independent concerns.
- Splitting into new contexts before the business language is stable enough to name them clearly.
- Mistaking a large Rails namespace for a bounded context without checking whether it has a single, coherent set of rules and an identifiable owner.

## Extended Resources

- [EXAMPLES.md](EXAMPLES.md) includes a worked leakage example (Fleet/Billing context boundaries).

## Output Style

1. **Finding Format**: For each finding include:
   - **Severity**
   - **Contexts involved**
   - **Leaked term / ownership conflict**
   - **Why the current boundary is risky**
   - **Smallest credible improvement**
2. **Structure**: Write findings first, then list open questions and recommended next skills.
3. **Language**: Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **define-domain-language** | When the review is blocked by fuzzy or overloaded terminology |
| **model-domain** | When a context is clear and needs entities/value objects/services modeled cleanly |
| **review-architecture** | When the same problem also needs a broader Rails structure review |
| **refactor-code** | When the recommended improvement needs incremental extraction instead of a rewrite |
