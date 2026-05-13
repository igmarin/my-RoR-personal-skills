---
name: plan-tickets
license: MIT
description: >
  Drafts, classifies, and optionally creates tickets from an initiative plan.
  Use when the user provides a plan and wants ticket drafts, wants help shaping
  a plan into tickets, wants sprint-placement guidance, or wants tickets created in
  an issue tracker after the plan is approved.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Plan Tickets

Normalize inputs, classify each work item, apply title conventions, draft tickets in a standard structure, then either return markdown drafts or create issues in the issue tracker after explicit approval.

## Quick Reference

```text
Plan input -> classify each item -> draft tickets -> confirm before tracker creation
Default mode: draft-only, unless the user explicitly asks to create issues.
Ticket shape: Title, Type, Area, Bucket, Summary, Background, Acceptance Criteria, Dependencies, Technical Notes.
```

## HARD-GATE

```text
Do not create tracker issues unless the user explicitly asks for creation.
Do not assume tracker credentials, project fields, sprint IDs, status behavior, or required custom fields.
If the user only asks for tickets, return markdown drafts.
```

## Core Process

### 1. Normalize the initiative

Extract planning inputs:
- initiative/theme
- project/board
- whether the request is **draft-only** or **create-in-tracker**
- default sprint or backlog bucket
- constraints on issue types, prefixes, epic, labels, components, status, or sprint

If the user already has a plan, **do not re-plan** unless there is a material gap.

### 2. Classify each ticket before drafting it

Assign these core planning attributes to each ticket:

| Attribute | Values |
|-----------|--------|
| `type` | `Story` \| `Task` |
| `area` | `backend` \| `web` \| `mobile` \| `cross-platform` \| `external` |
| `execution_order` | `foundation` \| `api` \| `client` \| `follow-up` |
| `dependency_level` | `unblocked` \| `blocked` |
| `target_bucket` | `ready-to-refine` \| `next-dev-sprint` \| `later` |

Additional attributes to apply when relevant: `coordination_need` (`single-team` | `multi-team`), `external_dependency` (`yes` | `no`), `urgency` (`normal` | `priority`).
Backend/API enablers generally come before dependent web/mobile tickets.

### 3. Apply Sprint Placement Heuristics
Defaults unless the user overrides:
- `foundation` and `api` tickets → placed **before** all dependent `client` tickets
- `client` tickets → blocked until the API surface they depend on is stable
- `external` confirmation tickets → excluded from active build sprints
- `follow-up` tickets → `ready-to-refine` or `later` until their enabling work is complete
- Named future sprints (e.g. **Ready to Refine**) → treat as a **planning bucket**, not an execution commitment

### 4. Apply title conventions

Use these prefixes:
- `BE |` for backend
- `FE |` for web / frontend
- `Mobile |` for mobile

When writing the ticket title, leave a space after the `|`. Do **not** add those prefixes to tickets that are not owned by those areas unless the user explicitly wants that.

### 5. Draft tickets in the standard structure

Use this section order:

| Section | Job |
|---------|-----|
| **Summary** | State the outcome |
| **Background** | Explain why |
| **Acceptance Criteria** | List observable criteria |
| **Dependencies** | Note blockers |
| **Technical Notes** | Implementation details that affect sequencing or scoping only |

Keep the main sections business-facing.

### 6. Output: drafts or create in the issue tracker

**Draft-only:**
- Return markdown tickets following the five-section structure (Summary, Background, Acceptance Criteria, Dependencies, Technical Notes) with the appropriate area prefix in the title.
- Keep titles, issue types, and dependencies explicit.
- Include brief sequencing notes when helpful.

**Create in issue tracker:**
- Verify the target project/board details first.
- Confirm required fields: project, issue type, sprint, status behavior, epic, labels, components.
- Create issues **only after** the plan is considered approved enough.
- Use whatever integration the user has (API, MCP, UI); do not assume credentials in the repo.
- Validate **one** issue before bulk-creating if the sprint field or workflow behavior is uncertain.
- Omit fields the project does not require. Confirm actual field names from the tracker's create-metadata endpoint before issuing the call. Do not set status on create — use the project's default initial status.
- After creation, report: created issue keys, confirmed status, confirmed sprint/bucket, and any assumptions used.

**Example field shape for MCP/API creation:**
```json
{
  "project": "<project-key>",
  "issuetype": "Story",
  "summary": "BE | Enable payment webhook processing",
  "description": "<full ticket body>",
  "labels": ["payments", "backend"],
  "components": ["payments-service"],
  "sprint": { "id": "<sprint-id>" },
  "epic": "<epic-key>"
}
```

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[EXAMPLES.md](./EXAMPLES.md)** — Use when you need a full plan → ticket draft example with classification applied.
- **[assets/ticket-samples/sample_issue.md](assets/ticket-samples/sample_issue.md)** — Use when you need the detailed format for a single issue.

## Output Style

When asked to draft tickets, your output MUST include:

1. **Ticket title** — Use `BE |`, `FE |`, or `Mobile |` only when the ticket is owned by that area.
2. **Classification line** — State `type`, `area`, `execution_order`, `dependency_level`, and `target_bucket` for every ticket.
3. **Five required sections** — `Summary`, `Background`, `Acceptance Criteria`, `Dependencies`, and `Technical Notes`, in that order.
4. **Observable acceptance criteria** — Write criteria a reviewer can verify without reading the agent's hidden process.
5. **Sequencing note** — Call out which tickets must happen before dependent client or follow-up tickets.
6. **Assumptions** — State assumptions about tracker, sprint, labels, components, or missing plan details.
7. **Creation boundary** — If not creating issues, explicitly state that the output is draft-only. If creating issues, report created issue keys and any skipped fields.
8. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|----------------|
| **generate-tasks** | After tasks exist or in parallel — same initiative can feed ticket breakdown |
| **create-prd** | When tickets should align with PRD scope and acceptance themes |