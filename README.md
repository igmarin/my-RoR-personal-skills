# Cursor Agent Skills

Personal [Cursor](https://cursor.com) agent skills for a **software engineer** working with **Ruby on Rails**. The focus is **best practices** and a **clear order of work**: from product requirements and task breakdown to implementation, testing, and code review.

These skills are used by Cursor's AI to keep responses aligned with Rails conventions, structured workflows, and consistent quality.

---

## How skills work

- **Where they live:** Cursor loads skills from `~/.cursor/skills/`. Each subfolder that contains a `SKILL.md` file is one skill (see [Setup](#setup-sync-across-machines) below to point that path to this repo).
- **When they’re used:** The AI may apply a skill automatically when your request matches the skill’s description (e.g. “write RSpec tests” → rspec-best-practices). You can also **@-mention** a skill by name in the chat to force its use.
- **After setup:** Once the repo is linked (or copied) to `~/.cursor/skills`, the skills are available in Cursor. If you don’t see them, try restarting Cursor.

---

## Workflow: Planning → Tasks → Implementation

Preferred order for new features:

1. **Define requirements** — [create-prd](create-prd/) turns a feature idea into a Product Requirements Document (goals, user stories, functional requirements, non-goals).
2. **Break down work** — [generate-tasks](generate-tasks/) turns the PRD (or a feature description) into a step-by-step task list with relevant files and checkboxes.
3. **Implement** — Use the task list and the Rails/stack skills below so code and tests follow the same standards.

---

## Skills Overview

### Planning & Tasks

| Skill                              | Purpose |
|------------------------------------|---------|
| [create-prd](create-prd/)          | Generate a PRD from a feature description (with optional clarifying questions). |
| [generate-tasks](generate-tasks/)   | Generate an implementation task list from a PRD or feature description; supports phased (parent → sub-tasks) or one-shot output. |

### Rails Conventions & Code Quality

| Skill                              | Purpose |
|------------------------------------|---------|
| [rails-stack-conventions](rails-stack-conventions/) | Conventions for **writing** Rails code: Ruby 3.x, PostgreSQL, Hotwire (Turbo/Stimulus), Tailwind CSS, style, structure, and security. |
| [rails-code-review](rails-code-review/)             | Checklist for **reviewing** Rails code (routing, controllers, models, migrations, queries, security, etc.) based on "The Rails Way." |

### Rails Background Jobs

| Skill                                    | Purpose |
|------------------------------------------|---------|
| [rails-background-jobs](rails-background-jobs/) | Active Job, Solid Queue (Rails 8), Sidekiq; idempotency, retries, recurring jobs; Rails 8 vs 7; PostgreSQL/MySQL. |

### Ruby Patterns

| Skill                                          | Purpose |
|------------------------------------------------|---------|
| [ruby-service-objects](ruby-service-objects/) | How to structure and document service objects (namespacing, `.call`, responses, transactions). |
| [ruby-api-client-integration](ruby-api-client-integration/) | Layered API client pattern: Auth, Client, Fetcher, Builder, domain entities. |
| [strategy-factory-null-calculator](strategy-factory-null-calculator/) | Variant-based calculators: Strategy + Factory + Null Object (single entry point, safe fallback). |

### Testing (RSpec)

| Skill                              | Purpose |
|------------------------------------|---------|
| [rspec-best-practices](rspec-best-practices/)   | Write and review maintainable, deterministic RSpec tests; design specs, choose spec types, fix flaky tests, improve factories, refactor suites for clarity, speed, and confidence. |
| [rspec-service-testing](rspec-service-testing/) | RSpec patterns for **service objects**: `instance_double`, FactoryBot, shared examples, matchers, `spec/services/` layout. |
| [rails-engine-testing](rails-engine-testing/)   | Design and implement tests for Rails engines: dummy app, request/routing/generator specs, reload-safety, host integration. |

### Rails Engines

| Skill                                      | Purpose |
|--------------------------------------------|---------|
| [rails-engine-author](rails-engine-author/) | Design and create Rails engines: scaffolding, mountable engine, engine.rb, namespaces, file layout, host-app contract. |
| [rails-engine-testing](rails-engine-testing/) | Test coverage for engines (dummy app, request specs, routing, generators, integration). |
| [rails-engine-reviewer](rails-engine-reviewer/) | Review engines for architecture, coupling, host integration, install flow, dummy-app coverage. |
| [rails-engine-release](rails-engine-release/) | Prepare engines for release: gemspec, changelog, deprecations, semantic versioning, migration notes. |
| [rails-engine-docs](rails-engine-docs/)   | Documentation for engines: README, installation, configuration, host integration examples, mount instructions. |
| [rails-engine-installers](rails-engine-installers/) | Install and setup flows: generators, migrations, initializers, route mount, idempotent install tasks. |
| [rails-engine-extraction](rails-engine-extraction/) | Extract app code into an engine incrementally: adapters, preserving behavior, safe extraction slices. |
| [rails-engine-compatibility](rails-engine-compatibility/) | Compatibility across Rails/Ruby versions: Zeitwerk, autoloading, upgrades, dependency bounds, assets, jobs. |

### Review & Safety

| Skill                                          | Purpose |
|------------------------------------------------|---------|
| [rails-architecture-review](rails-architecture-review/) | Review application architecture: boundaries, fat models/controllers, callbacks, concerns, service extraction. |
| [rails-security-review](rails-security-review/)         | Review for security risks: auth, params, redirects, file uploads, secrets, XSS, CSRF, injection. |
| [rails-migration-safety](rails-migration-safety/)       | Plan and review production-safe migrations: columns, indexes, backfills, renames, concurrent ops, rollout. |

### Refactoring

| Skill                          | Purpose |
|--------------------------------|---------|
| [refactor-safely](refactor-safely/) | Plan and execute low-risk refactors: restructuring, renaming, extracting services/modules, preserving behavior. |

---

## How skills relate

- **Planning:** create-prd → generate-tasks (then implement using the skills below).
- **Rails:** rails-stack-conventions = *writing* code; rails-code-review = *reviewing* code. Use both for the same codebase.
- **Background jobs:** rails-background-jobs = designing and implementing jobs (Solid Queue in Rails 8, Sidekiq, idempotency, retries, recurring). Use when adding or reviewing job classes and queue configuration.
- **Ruby patterns:** ruby-service-objects is the base; ruby-api-client-integration and strategy-factory-null-calculator are specific patterns (API layers, variant calculators). Each references the others where they overlap.
- **Testing:** rspec-best-practices = general RSpec (any spec type, design, flaky fixes, refactor); rspec-service-testing = specs for services (templates, instance_double, shared_examples); rails-engine-testing = engine coverage with dummy app. Use rspec-best-practices for any spec; add rspec-service-testing when writing service specs; use rails-engine-testing for engine test setup and integration.
- **Engines:** rails-engine-author to create; rails-engine-testing to test; rails-engine-reviewer to review; rails-engine-release, -docs, -installers, -extraction, -compatibility for release, docs, install flow, extraction, and version compatibility.
- **Review:** rails-code-review for general Rails PRs; rails-architecture-review for structure and boundaries; rails-security-review for security; rails-engine-reviewer for engine-specific review; rails-migration-safety for schema changes.

---

## When to use which (Quick reference)

| If you want to…                                                   | Use |
|-------------------------------------------------------------------|-----|
| Write or review specs (models, requests, features, jobs)         | [rspec-best-practices](rspec-best-practices/) |
| Write service object specs                                       | [rspec-best-practices](rspec-best-practices/) + [rspec-service-testing](rspec-service-testing/) |
| Test a Rails engine (dummy app, integration)                     | [rails-engine-testing](rails-engine-testing/) |
| Review Rails code (PR, conventions)                              | [rails-code-review](rails-code-review/) |
| Review architecture / boundaries / fat models                     | [rails-architecture-review](rails-architecture-review/) |
| Review an engine (coupling, integration)                         | [rails-engine-reviewer](rails-engine-reviewer/) |
| Review security (auth, params, XSS, etc.)                       | [rails-security-review](rails-security-review/) |
| Production-safe migrations                                       | [rails-migration-safety](rails-migration-safety/) |
| Add or configure background jobs (Solid Queue, Sidekiq, recurring) | [rails-background-jobs](rails-background-jobs/) |
| Create or refactor an engine                                     | [rails-engine-author](rails-engine-author/) |
| Refactor code without breaking behavior                          | [refactor-safely](refactor-safely/) |

---

## Setup (Sync Across Machines)

To use these skills in Cursor (and keep them in sync across machines):

```bash
# Clone this repo where you prefer (e.g. ~/repos/cursor-skills)
git clone https://github.com/YOUR_USERNAME/cursor-skills.git ~/repos/cursor-skills

# Link Cursor's skills directory to this repo
rm -rf ~/.cursor/skills
ln -s ~/repos/cursor-skills ~/.cursor/skills
```

After that, `git pull` on each machine keeps skills in sync; changes in `~/.cursor/skills` are changes in the repo.

---

## Public vs private repo

- **Public:** Anyone can see and clone your skills. Useful if you want to share conventions or use the same repo from multiple machines without auth. No secrets are stored here (only Markdown), so making it public is safe.
- **Private:** Only you (and collaborators you add) can access it. You'll need SSH keys or a personal access token to clone on each machine.

Choose whichever fits how you work. The skills themselves behave the same either way.

## License

Use and adapt as you like. If the repo is public, others can reuse or fork these skills.
