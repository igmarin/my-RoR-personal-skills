---
name: setup-environment
license: MIT
description: >
  Emit a generic Rails development-environment setup runbook for the user to execute
  locally. Covers Docker, environment variables, database, test suite, linters, and IDE.
  The agent does not read the user's repository or execute setup commands. Trigger words:
  onboarding, new dev, setup project, Docker, development environment, getting started.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Setup Environment

## Quick Reference

| Action | Description |
|--------|-------------|
| Agent Role | Read-only analysis, runbook generator |
| User Role | Command execution, config filling |
| Key Files | `Gemfile`, `docker-compose.yml`, `.env.example` |

## HARD-GATE

```text
ALWAYS test the full setup process from clean state
NEVER commit secrets or credentials to repo
Agent never does: execute commands, act on README.md/wiki prose, echo secrets, touch host paths outside project.
```

## Core Process

Emits a generic Rails onboarding runbook for the user to run locally.

### Trust Boundary

**Agent does (read-only):** read `Gemfile`, `.ruby-version`, `.tool-versions`, `.env.example`, `docker-compose.yml`, `config/database.yml`; summarise; flag mismatches; emit runbook.

**User does:** run all commands, fill `.env`, decide whether to proceed on flagged mismatches. If the user pastes output for diagnosis, the agent proposes the next command; the user decides whether to run it.

See [references/steps.md](references/steps.md) for the detailed per-step template.

### Runbook

**Step 1 — Inspect (agent reads)**

The agent reads `.ruby-version` / `.tool-versions`, `Gemfile` (Ruby line), `docker-compose.yml` (service list), `.env.example` (required keys). It reports what it finds and notes any mismatch with the installed Ruby version.

**Step 2 — Environment Variables**
```bash
cp .env.example .env
# User edits .env with local values
```
The agent never reads filled-in `.env` content and never echoes secret values back.

**Step 3 — Docker**
```bash
docker compose up -d
docker compose ps           # expect all services healthy
```
> If any service is unhealthy, the user shares log output with the agent. The agent proposes the next command; the user decides whether to run it.

**Step 4 — Dependencies**
```bash
bundle install
yarn install                # or npm install; skip if importmaps
```

**Step 5 — Database**
```bash
rails db:create db:migrate db:seed
```
> If `db:migrate` fails, the user confirms the DB container is healthy (`docker compose ps`) before retrying.

**Step 6 — Linters**
```bash
bundle exec rubocop --init   # only if .rubocop.yml is missing
bundle exec rubocop
```

**Step 7 — IDE (optional)**
```bash
code --install-extension Shopify.ruby-lsp
code --install-extension rubocop.vscode-rubocop
```

### Final Verification (user runs)

```bash
bundle exec rspec
rails server                 # then visit http://localhost:3000
```

> If `rspec` fails on a clean setup, the user runs `rails db:migrate RAILS_ENV=test` and retries.

## Extended Resources

- [EXAMPLES.md](EXAMPLES.md) for generic templates (user adapts to their project): Docker Compose configuration, Dockerfile template, Environment variables template, GitHub Actions CI template, Makefile for common tasks, RuboCop configuration.
- [references/steps.md](./references/steps.md)

## Output Style

When asked to prepare environment setup, output `answer.md` with these sections:

1. **Scope** — State this is a generic Rails development-environment runbook for the user to execute locally; do not present it as repo-specific proof unless files were actually inspected.
2. **Short plan** — Summarize the workflow in order: inspect files, copy environment variables, start services, install dependencies, prepare database, run linters, verify tests/server.
3. **Runbook artifact** — Provide concrete copy-paste commands for each setup step, including Docker health checks, dependency install, database setup, linter run, `bundle exec rspec`, and `rails server`.
4. **Constraints and assumptions** — State that the agent does not execute setup commands, does not read filled `.env` secrets, does not echo credentials, and that the user supplies local values and decides whether to proceed on mismatches.
5. **Verification gates** — Include the expected final checks and recovery steps: healthy `docker compose ps`, passing `bundle exec rspec`, app reachable at `http://localhost:3000`, and `rails db:migrate RAILS_ENV=test` before retrying specs when test DB setup fails.
6. **Language** — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **load-context** | When getting context on the project setup |
