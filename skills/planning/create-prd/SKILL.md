---
name: create-prd
license: MIT
description: >
  Generates a clear, actionable Product Requirements Document (PRD) in Markdown
  from a feature description and saves it to /tasks/prd-FEATURE-SLUG.md following
  PRD_TEMPLATE.md. Use when a user asks to plan a feature, define requirements,
  create a PRD, or write a product spec. Covers goals, user stories, functional
  requirements, non-goals, design and technical considerations, implementation
  surface, success metrics, and open questions for Rails-oriented workflows.
  Trigger words: PRD, product requirements, plan a feature, write a spec,
  requirements document, /tasks/ folder.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Generating a Product Requirements Document (PRD)

Focus on *what* and *why*, not *how*. No code until the PRD is approved.

## Quick Reference

- **Goal:** Draft a clear, actionable PRD from a feature request.
- **Constraints:** Focus on what/why. No code snippets. Save to `/tasks/prd-<slug>.md`.
- **Flow:** Clarify if ambiguous -> Draft PRD using template -> Ask for explicit approval.

## HARD-GATE

```text
Focus exclusively on WHAT and WHY, not HOW. 
DO NOT include any code, pseudo-code, SQL, class names, method signatures, or migration syntax in the PRD.
DO NOT generate implementation tasks or write code until the PRD has been explicitly approved by the user.
```

## Core Process

1. **Receive prompt** — feature description or request.
2. **Clarify only if needed** — if the goal, scope, and success signals are already clear, skip questions and draft the PRD. If ambiguous, ask **3–5** targeted questions (see [assets/prd_questions.md](./assets/prd_questions.md) for areas to pull from).
3. **Draft** — fill **[PRD_TEMPLATE.md](./PRD_TEMPLATE.md)** section by section (canonical order and Rails-oriented fields). Do not invent a parallel outline.
4. **Validate** — present the PRD; get **explicit approval** before implementation, tasks, or code.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[PRD_TEMPLATE.md](./PRD_TEMPLATE.md)** — Mandatory Markdown structure every PRD follows.
- **[assets/prd_questions.md](./assets/prd_questions.md)** — Clarification inventory (not an obligatory 12-question form).
- **[assets/examples.md](./assets/examples.md)** — Short one-pager + full PRD example aligned to the template.

## Rails-specific notes

- Mention Rails only when it **constrains scope** (auth, jobs, timeouts, conventions), not as step-by-step implementation.
- Call out effects on **middleware, callbacks, or workers** in **Design and Technical Considerations** or **Non-Functional Requirements** when relevant.

## Output Style

When generating a PRD, your output MUST include:

1. **Save Location** — Save to `/tasks/prd-<feature-slug>.md` (lowercase, kebab-case slug — e.g. `/tasks/prd-google-oauth-login.md`). State the path in your response.
2. **Template adherence** — Follow [PRD_TEMPLATE.md](./PRD_TEMPLATE.md) section by section, in order. Every section appears, even if short or marked "TBD".
3. **Functional Requirements language** — Written in natural language ("the system must send a confirmation email when…"), not Ruby.
4. **Next Steps** — Close the PRD with the suggested follow-on (typically: "Run `generate-tasks` against this PRD once approved.").
5. **No Code** — Never include code, pseudo-code, SQL, class names, method signatures, or migration syntax.
6. **Language** — Must be in English unless explicitly requested otherwise.

After saving, surface the file path and request explicit approval before any implementation or task generation.

## Integration

| Skill | When to chain |
|-------|---------------|
| **generate-tasks** | After the PRD is approved, to derive implementation steps |
| **plan-tickets** | When the user needs Jira/tracker tickets based on the approved PRD scope |