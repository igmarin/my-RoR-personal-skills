# Rails Agent Skills — Documentation

> **AI-Driven Rails Engineering:** We turn coding assistants into reliable engineers through structured workflows, action-oriented skills, and a non-negotiable TDD quality gate.

This documentation defines the "operating system" for your development.

---

## 🚀 Quick Start decision map

Pick your current stage and follow the expert workflow.

| If you are... | Use this... |
|---------------|----------|
| **New to the project** | `load-context` → [Discovery Guide](workflows/discovery.md) |
| **Ready to build a feature** | [TDD Workflow](workflows/development.md) |
| **Reviewing code** | [Review Workflow](workflows/review.md) |
| **Not sure where to start** | `skill-router` (The entry point) |

---

## Architecture: Skills vs. Workflows

To save your token budget and keep the agent focused, we use a hybrid architecture:

1.  **Workflows (Resources):** These are high-level guides (like the ones in `workflows/`) that the agent sees as "Resources". They tell the agent *how* to chain steps together.
2.  **Skills (Tools):** These are atomic, expert instructions (like `code-review` or `refactor-code`). The agent loads them on-demand using the `use_skill(name:)` tool.

---

## Master Workflow Index

| Stage | Guide | Description | Primary Skills |
|-------|----------|-------------|----------------|
| **Discovery** | [Discovery & Context](workflows/discovery.md) | Understand codebase & onboarding | `load-context`, `setup-environment` |
| **Planning** | [Planning & Design](workflows/planning.md) | PRDs, tasks, and DDD | `create-prd`, `generate-tasks`, `define-domain-language` |
| **Setup** | [Setup & Configuration](workflows/setup.md) | CI/CD & infrastructure | `setup-environment`, `setup-ci-cd` |
| **Development** | [Development](workflows/development.md) | TDD & Implementation | `plan-tests`, `write-tests`, `triage-bug` |
| **Quality** | [Code Quality](workflows/quality.md) | Conventions & refactoring | `apply-code-conventions`, `refactor-code`, `write-yard-docs` |
| **Review** | [Review & Validation](workflows/review.md) | Review, security, & architecture | `code-review`, `security-check`, `review-architecture` |
| **Engines** | [Engine Development](workflows/engines.md) | Building Rails engines | `create-engine`, `release-engine` |

---

## Core Principles

### 🧪 Tests Gate Implementation
We never write implementation code until a test exists, runs, and fails. **No exceptions.**

### 🔗 Workflow Chaining
Skills are building blocks; workflows are the story. Follow the `skill-router` to find the right chain.

---

## Reference & Authoring

- **[Skill Catalog](reference/skill-catalog.md)** — Complete list of 41 skills with triggers.
- **[Integration Matrix](reference/integration-matrix.md)** — How skills connect.
- **[Skill Template](skill-template.md)** — For creating new skills.
- **[Implementation Guide](implementation-guide.md)** — IDE Setup (MCP Server).
