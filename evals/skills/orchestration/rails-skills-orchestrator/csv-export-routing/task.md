# Route an Ambiguous Feature Request to the Right Skills

## Problem/Feature Description

You are acting as the `rails-skills-orchestrator`. A developer arrives with the following request:

> "I need to add export functionality to our reporting module. Users should be able to download their reports as CSV. We also want to make sure we're doing this the right way — tests first — and the endpoint should be secure."

Using the orchestrator skill, analyze the request, identify the **primary skill** and any **supporting skills** that should be applied, explain why, and produce a structured skill-loading plan.

You MUST NOT generate any Ruby code. This task is purely about skill routing.

## Output Specification

Produce a single file:

- `docs/skill_routing_plan.md` — A structured plan containing:

  1. **Request Analysis** — A brief (≤5 sentences) decomposition of what the request involves
  2. **Primary Skill** — The single skill that owns the main workflow, with the full skill path (e.g. `skills/testing/rails-tdd-slices`)
  3. **Supporting Skills** — An ordered list of supporting skills to chain, each with:
     - Full skill path
     - One-sentence justification for why it's needed
  4. **Execution Order** — A numbered sequence showing the order in which the skills should be loaded and applied
  5. **Skills Explicitly Excluded** — At least 2 skills that a developer might wrongly reach for, with a brief explanation of why they don't apply
