# Cursor Agent Skills

Personal [Cursor](https://cursor.com) agent skills for a **software engineer** working with **Ruby on Rails**. The focus is **best practices** and a **clear order of work**: from product requirements and task breakdown to implementation, testing, and code review.

These skills are used by Cursor’s AI to keep responses aligned with Rails conventions, structured workflows, and consistent quality.

---

## Workflow: Planning → Tasks → Implementation

Preferred order for new features:

1. **Define requirements** — [create-prd](create-prd/) turns a feature idea into a Product Requirements Document (goals, user stories, functional requirements, non-goals).
2. **Break down work** — [generate-tasks](generate-tasks/) turns the PRD (or a feature description) into a step-by-step task list with relevant files and checkboxes.
3. **Implement** — Use the task list and the Rails/stack skills below so code and tests follow the same standards.

---

## Skills Overview

### Planning & Tasks

| Skill | Purpose |
|-------|---------|
| [create-prd](create-prd/) | Generate a PRD from a feature description (with optional clarifying questions). |
| [generate-tasks](generate-tasks/) | Generate an implementation task list from a PRD or feature description; supports phased (parent → sub-tasks) or one-shot output. |

### Rails Conventions & Code Quality

| Skill | Purpose |
|-------|---------|
| [rails-stack-conventions](rails-stack-conventions/) | Conventions for **writing** Rails code: Ruby 3.x, PostgreSQL, Hotwire (Turbo/Stimulus), Tailwind CSS, style, structure, and security. |
| [rails-code-review](rails-code-review/) | Checklist for **reviewing** Rails code (routing, controllers, models, migrations, queries, security, etc.) based on “The Rails Way.” |

### Ruby Patterns

| Skill | Purpose |
|-------|---------|
| [ruby-service-objects](ruby-service-objects/) | How to structure and document service objects (namespacing, `.call`, responses, transactions). |
| [ruby-api-client-integration](ruby-api-client-integration/) | Layered API client pattern: Auth, Client, Fetcher, Builder, domain entities. |
| [strategy-factory-null-calculator](strategy-factory-null-calculator/) | Variant-based calculators: Strategy + Factory + Null Object (single entry point, safe fallback). |

### Testing (RSpec)

| Skill | Purpose |
|-------|---------|
| [rspec-best-practices](rspec-best-practices/) | General RSpec practices: coverage, readability, structure, `let`/`subject`, factories, isolation, shared examples. |
| [rspec-service-testing](rspec-service-testing/) | RSpec patterns for **service objects**: `instance_double`, FactoryBot, shared examples, matchers, `spec/services/` layout. |

---

## How skills relate

- **Planning:** create-prd → generate-tasks (then implement using the skills below).
- **Rails:** rails-stack-conventions = *writing* code; rails-code-review = *reviewing* code. Use both for the same codebase.
- **Ruby patterns:** ruby-service-objects is the base; ruby-api-client-integration and strategy-factory-null-calculator are specific patterns (API layers, variant calculators). Each references the others where they overlap.
- **Testing:** rspec-best-practices = general RSpec; rspec-service-testing = specs for services (templates, instance_double, shared_examples). Use both when writing service specs.

---

## Setup (Sync Across Machines)

To use the same skills on multiple computers via this repo:

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
- **Private:** Only you (and collaborators you add) can access it. You’ll need SSH keys or a personal access token to clone on each machine.

Choose whichever fits how you work. The skills themselves behave the same either way.

## License

Use and adapt as you like. If the repo is public, others can reuse or fork these skills.
