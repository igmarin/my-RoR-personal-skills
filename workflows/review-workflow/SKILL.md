---
name: review-workflow
license: MIT
description: >
  Multi-pass Rails code review workflow that identifies bugs, security vulnerabilities, and architectural issues; assigns severity levels (Critical, Suggestion, Nice-to-have); and generates actionable review comments with a mandatory re-review loop for Critical findings. Use for full PR review workflows, multi-pass security or architecture audits, or implementing and verifying responses to review feedback. Trigger: review this PR, full code review, multi-pass review, audit security vulnerabilities, review architecture, respond to review feedback, implement review fixes.
keywords: rails, review, audit, security, architecture, workflow, pr, feedback
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Review Workflow

Orchestrates systematic code review with optional deep dives for security/architecture and response handling.

## Workflow Phases

### Phase 1: Systematic Review

**Load primary review skill:**
1. **code-review** — Systematic Rails PR review

**Concrete checklist per changed file:**
- Verify `before_action` callbacks match route constraints and cover all sensitive actions
- Check every `.save`, `.update`, `.destroy` call has error handling or a `!` bang with rescue
- Confirm strong parameters whitelist only the required attributes — no `permit!`
- Identify any `where`/`find` calls inside loops (N+1 risk) and flag for extraction
- Confirm `authorize` (or equivalent policy check) is called before rendering any resource
- Validate model associations use appropriate `dependent:` options to prevent orphaned records
- Check callbacks (`before_save`, `after_create`, etc.) for side-effects that cross domain boundaries
- Confirm test coverage exists for the changed logic path

**Output format per file:** `[CRITICAL|SUGGESTION|NICE-TO-HAVE] <file>:<line> — <finding>`

**Example Critical finding comment:**
```
[CRITICAL] app/controllers/orders_controller.rb:42 — Missing authorisation check;
  any authenticated user can access another user's order. Add `authorize @order`
  before rendering.
```

**Example Suggestion comment:**
```
[SUGGESTION] app/models/order.rb:17 — `Order.where(user: current_user)` called
  inside a loop; extract to a scoped query to avoid N+1.
```

**Decision Gate — Security Check:**
- Security concerns found? → Proceed to Phase 2 (Security)
- No security concerns → Skip to Phase 2 (Architecture check)

---

### Phase 2: Deep Dive (Optional)

**Branch A — Security Review (if triggered):**
- **skills/code-quality/security-check** — Deep security audit
  - Auth & session management
  - Authorization & IDOR
  - Input validation & SQL injection
  - Output encoding & XSS
  - Secrets handling

**Decision Gate — Architecture Check:**
- Architecture issues found? → Proceed to Architecture Review
- No architecture issues → Skip to Phase 3

**Branch B — Architecture Review (if triggered):**
- **skills/code-quality/review-architecture** — Structural review
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
1. **skills/code-quality/respond-to-review** — Evaluate and implement fixes
2. **Validation checkpoint** — For each Critical item, confirm a corresponding code change exists before marking resolved:
   - List each Critical finding by ID
   - For each: identify the changed file and line, verify the fix addresses the root cause
   - Only mark resolved when the change is present and correct
3. **Re-review mandatory** — Return to Phase 1 (code-review)
4. Repeat until all Critical items are resolved

**Proceed-to-merge summary format:**
```
## Review Complete — Approved for Merge
- Critical findings: 0 remaining
- Suggestions addressed: <n> fixed, <n> ticketed as <TICKET-IDs>
- Files reviewed: <list>
- Re-review cycles: <n>
```

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
