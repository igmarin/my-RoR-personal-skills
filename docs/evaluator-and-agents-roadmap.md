# Evaluator and Agents Roadmap

This roadmap now reflects the repository as it exists today: the evaluator already runs a ReAct loop, the repo already uses root `workflows/`, and the next step is hardening those foundations before any agent-framework expansion.

## Current State

- `workflows/` is already the published home for callable workflow skills.
- `evals/` already mirrors the source layout with `evals/skills/` and `evals/workflows/`.
- The evaluator already compares a baseline run against a context-hydrated ReAct run.
- MCP exposure, manifests, and docs still need enforcement so they match the on-disk topology consistently.

## Phase 3A: Hardening and Enforcement Gate

**Goal:** Make the current evaluator and published skill surface internally consistent before new architecture work begins.

### Mandatory fixes in this gate

1. **MCP topology enforcement**
   - Discover published skills from `build/` and `skills/<category>/<skill>/`.
   - Discover workflows from `workflows/<workflow>/`.
   - Discover docs from `docs/`.
   - Keep supported Tessl tile discovery only as a compatibility path.

2. **Manifest and inventory enforcement**
   - Publish every callable public skill consistently across `tile.json` and `.claude-plugin/plugin.json`.
   - Keep `scripts/validate-plugins.sh` strict so disk-vs-manifest drift fails immediately.
   - Treat `build/SKILL.md` as a first-class published skill.

3. **Evaluator source-path enforcement**
   - Infer source paths directly from eval targets by convention.
   - Keep `--skill` as an explicit override, not a mandatory input.
   - Record the resolved source path actually used in reports and benchmark history.

4. **Documentation alignment**
   - Remove stale `.windsurf/workflows` assumptions from runtime docs.
   - Describe the evaluator as ReAct-based, not one-shot.
   - Keep roadmap language aligned with the real repo structure and current evaluator behavior.

### Exit criteria

- MCP resources, manifest inventories, evaluator source mapping, and roadmap docs all describe the same topology.
- `scripts/validate-plugins.sh` passes with no inventory exceptions.
- Evaluator and MCP tests cover the enforced conventions.

## Phase 3B: Standalone Evaluator Extraction

**Goal:** Extract the hardened evaluator into a standalone gem only after the enforcement gate is complete.

1. Extract the stabilized evaluator code into an independent Ruby gem.
2. Re-integrate it into this repository as a dependency with the same ReAct behavior.
3. Preserve convention-based source resolution and benchmark history during the extraction.

This extraction is intentionally *after* the hardening batch so the gem boundary is cut from stable behavior, not from drifting assumptions.

## Phase 4: Agent Transition Work

**Goal:** Expand from a hardened ReAct evaluator into richer agent execution only after Phase 3A and Phase 3B are complete.

1. Reuse the evaluator's ReAct runtime, tool execution, and context hydration as the foundation.
2. Add longer-lived interactive execution, richer observability, and more agent-oriented orchestration.
3. Evaluate whether the eventual agent framework should extend the evaluator, the MCP layer, or a new runtime boundary.

## Guiding Rule

Do not start Phase 4 work while topology, manifest publication, evaluator source mapping, and roadmap docs still disagree. Hardening comes first, extraction comes second, and agent expansion comes last.
