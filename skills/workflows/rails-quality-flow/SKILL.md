---
name: rails-quality-flow
license: MIT
description: >
  Complete code quality workflow. Orchestrates conventions → refactoring → documentation.
  Use after implementation to ensure production quality. Trigger: code review prep,
  refactor safely, add documentation, quality check, before PR.
keywords: rails, quality, conventions, refactoring, documentation, yard, review
---

# Rails Quality Flow — Complete Quality Assurance Workflow

Orchestrates systematic code quality checks, safe refactoring, and documentation updates.

## When to Use

- Preparing code for review (before PR)
- Systematic refactoring with safety
- Adding documentation to existing code
- Quality audit of codebase

## Workflow Phases

### Phase 1: Conventions Review

**Check code against Rails standards:**
1. **skills/code-quality/rails-code-conventions** — Daily coding checklist
   - DRY/YAGNI/PORO/CoC/KISS compliance
   - Linter as style source of truth
   - Structured logging
   - Per-path rules

2. **skills/code-quality/rails-stack-conventions** — Stack-specific conventions
   - Rails + PostgreSQL patterns
   - Hotwire + Tailwind conventions
   - Security best practices

**Output:** Convention violations list with severity (must-fix vs should-fix vs nice-to-have)

---

### Phase 2: Refactoring (Optional)

**Only if code needs restructuring:**

**Decision Gate — Need Refactoring?**
- High complexity / low readability? → Proceed to refactoring
- Logic duplication found? → Proceed to refactoring
- Otherwise → Skip to documentation

**Refactoring Path:**
1. **skills/code-quality/refactor-safely** — Characterization tests first
2. Extract methods/classes with tests passing
3. Verify no behavioral changes

**HARD GATE — Tests Pass:**
- All existing tests pass
- New characterization tests written
- No functional changes introduced

---

### Phase 3: Documentation

**Document public APIs:**
1. **skills/patterns/yard-documentation** — YARD docs for Ruby classes
   - All public methods documented
   - Params and return values specified
   - Examples for complex methods

2. **Update README/diagrams:**
   - Architecture changes reflected
   - API changes documented
   - Setup instructions updated if needed

**Output:** Updated YARD comments, refreshed README sections

---

## Quick Reference

```
Before PR?       → rails-code-conventions → yard-documentation
Need to refactor? → refactor-safely → rails-code-conventions
Quality audit?   → rails-code-conventions → rails-stack-conventions
Not sure?        → rails-skills-orchestrator
```

## HARD-GATE: Quality Before Merge

**NEVER open PR before:**
1. Linters pass (RuboCop, ERBLint)
2. All tests pass
3. YARD docs complete for public APIs
4. Security scan passes (Brakeman)

**Why:** Technical debt compounds. Quality gates prevent it.

## Output Style

**Quality Report:**
```markdown
# Quality Report — [Date]

## Conventions Check
- [x] DRY: No duplication found
- [x] PORO: Service objects properly structured
- [ ] YAGNI: Remove unused method `calculate_total`?

## Refactoring
- Characterization tests: 5 added
- Methods extracted: 3
- All tests passing: YES

## Documentation
- YARD coverage: 87% (improved from 65%)
- README updated: YES
```

## Integration

| Predecessor | This Skill | Successor |
|-------------|------------|-----------|
| rails-tdd-loop (development complete) | rails-quality-flow | rails-review-flow |
| Any implementation skill | rails-quality-flow | rails-code-review |

**From AGENTS.md:** This is the quality workflow. Always run before review.
