---
name: create-prd
description: Generate a Product Requirements Document (PRD) in Markdown from a feature description. Use when the user asks to create a PRD, define product requirements, plan a feature, write a requirements doc, or mentions PRD.
---

# Generating a Product Requirements Document (PRD)

## Goal

Create a clear, actionable PRD in Markdown that a junior developer can use to understand and implement a feature. Focus on *what* and *why*, not *how*.

## When to Use

- User asks for a PRD, requirements doc, or to "plan a feature".
- User describes a feature and you need to capture it in a structured way before implementation.
- **Next step:** After saving the PRD, suggest: "Do you want me to generate an implementation task list from this PRD? (Use the generate-tasks skill.)"

## Process

1. **Receive prompt:** User provides a feature description or request.
2. **Decide on questions:**
   - If the prompt is **already detailed** (clear goal, scope, and success criteria), skip clarifying questions and generate the PRD directly.
   - If anything is **ambiguous**, ask only the most essential questions (3–5 max). Understand "what" and "why", not "how". Use letter/number options for quick answers.
3. **Generate PRD:** Use the structure below. Derive `[feature-name]` from the feature (lowercase, hyphenated slug, e.g. `user-onboarding`, `export-csv`).
4. **Save:** Save as `prd-[feature-name].md` in the `/tasks` directory (create the directory if needed).
5. **Do NOT** start implementing the PRD. Offer to generate tasks if the user wants an implementation checklist.

## Clarifying Questions (Only When Needed)

Ask only when the answer is not reasonably inferable. Typical areas:

- **Problem/Goal:** What problem does this solve for the user?
- **Core actions:** What are the key actions the user should perform?
- **Scope:** What should this feature *not* do?
- **Success:** How do we know it's done or successful?

### Question Format

Use numbered questions with A/B/C/D options when possible:

```
1. What is the primary goal of this feature?
   A. Improve onboarding
   B. Increase retention
   C. Reduce support load
   D. Other (describe)

2. Who is the target user?
   A. New users only
   B. Existing users only
   C. All users
```

## PRD Structure

Generate the document with these sections. Use concrete wording; avoid vague phrases.

1. **Introduction/Overview** — One short paragraph: what the feature is and what problem it solves.
2. **Goals** — Specific, measurable objectives (bullet list).
3. **User Stories** — "As a [role], I want [action] so that [benefit]." One per key flow.
4. **Functional Requirements** — Numbered list of must-have behaviors. Clear and testable.
5. **Non-Goals (Out of Scope)** — Explicitly what this feature will *not* include.
6. **Design Considerations (Optional)** — UI/UX notes, mockup links, or component references.
7. **Technical Considerations (Optional)** — Constraints, dependencies, or tech suggestions.
8. **Success Metrics** — How success will be measured (even if qualitative).
9. **Open Questions** — Anything still unclear or to be decided later.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/tasks/`
- **Filename:** `prd-[feature-name].md`

## Target Audience

Write for a **junior developer**: explicit, unambiguous, minimal jargon. Each requirement should be implementable without guessing.

## Final Instructions

1. Do **not** implement the PRD; only produce the document.
2. Ask clarifying questions only when the prompt is ambiguous; otherwise generate directly.
3. Incorporate user answers into the PRD when they were asked.
4. After saving, suggest generating an implementation task list from this PRD if appropriate.
