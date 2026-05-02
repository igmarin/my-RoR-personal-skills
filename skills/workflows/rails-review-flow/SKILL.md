---
name: rails-review-flow
license: MIT
description: >
  Complete code review workflow. Orchestrates systematic review → deep dive → response
  cycle with severity-based gates. Use for PR review, audit, or responding to feedback.
  Trigger: review PR, code review, audit security, check this code, respond to feedback.
keywords: rails, review, audit, security, architecture, workflow, pr, feedback
---

# Rails Review Flow — Complete Review Workflow

Orchestrates systematic code review with optional deep dives for security/architecture and response handling.

## When to Use

- Reviewing your own or others' code (PR ready)
- Security or architecture audit
- Responding to review feedback

## Workflow Phases

### Phase 1: Systematic Review

**Load primary review skill:**
1. **rails-code-review** — Systematic Rails PR review

**Decision Gate — Security Check:**
- Security concerns found? → Proceed to Phase 2 (Security)
- No security concerns → Skip to Phase 2 (Architecture check)

---

### Phase 2: Deep Dive (Optional)

**Branch A — Security Review (if triggered):**
- **skills/code-quality/rails-security-review** — Deep security audit
  - Auth & session management
  - Authorization & IDOR
  - Input validation & SQL injection
  - Output encoding & XSS
  - Secrets handling

**Decision Gate — Architecture Check:**
- Architecture issues found? → Proceed to Architecture Review
- No architecture issues → Skip to Phase 3

**Branch B — Architecture Review (if triggered):**
- **skills/code-quality/rails-architecture-review** — Structural review
  - Boundary recommendations
  - Extraction suggestions
  - Coupling assessment

---

### Phase 3: Respond

**Decision Gate — Findings Assessment:**

| Finding Level | Action |
|---------------|--------|
| **None/minor** | Proceed to merge |
| **Critical** | Must fix before merge |
| **Suggestion** | Fix in this PR or ticket separately |

**If Critical findings:**
1. **skills/code-quality/rails-review-response** — Evaluate and implement fixes
2. **Re-review mandatory** — Return to Phase 1 (rails-code-review)
3. Repeat until Critical items resolved

**If Suggestions only:**
1. Fix accepted items (one at a time)
2. Document deferred items as tickets
3. Proceed to merge

---

## Severity Levels

| Level | Definition | Action Required |
|-------|------------|-----------------|
| **Critical** | Security vulnerability, data loss, production risk | Fix before merge |
| **Suggestion** | Improvement opportunity, tech debt | Fix now or ticket |
| **Nice to have** | Optional enhancement | Does not block |

---

## Anti-Patterns to Avoid

- **Performative agreement:** "LGTM! Will address in follow-up" without actually fixing
- **Skipping re-review:** Critical fixes must be re-reviewed
- **Scope creep:** Don't turn review into feature work — ticket separately

---

## Integration

| After | Load |
|-------|------|
| Review complete, approved | Nothing — proceed to merge |
| Critical security finding | skills/code-quality/rails-security-review → fix → re-review |
| Architecture concern | skills/code-quality/rails-architecture-review → refactor → re-review |
| Feedback received | skills/code-quality/rails-review-response → implement → re-review |

---

## Output Language

All generated artifacts (review comments, findings reports) must be in **English** unless user explicitly requests another language.
