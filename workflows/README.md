# Workflows

This directory contains callable **Workflow Skills**. Unlike atomic skills, workflows are high-level orchestrators that chain multiple skills together to complete a complex development phase.

## Available Workflows

| Workflow | Description |
|----------|-------------|
| **[tdd-workflow](tdd-workflow/)** | Full TDD feature cycle: plan tests → write failing test → implement → review. |
| **[review-workflow](review-workflow/)** | Systematic PR review: code review → deep dive (security/architecture) → response. |
| **[quality-workflow](quality-workflow/)** | Pre-PR quality check: conventions → refactoring → documentation. |
| **[engine-workflow](engine-workflow/)** | End-to-end Rails engine development: scaffold → test → document → release. |
| **[setup-workflow](setup-workflow/)** | Project onboarding and CI/CD configuration. |

## How to use

Workflows are exposed as **MCP Resources**. To use one, an agent with ReAct capabilities (like Claude Code or Cursor) will load the workflow's `SKILL.md` to understand the full sequence of steps.

For a detailed narrative guide on these workflows, see **[docs/workflows/](../docs/workflows/README.md)**.
