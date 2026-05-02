---
name: rails-setup-flow
license: MIT
description: >
  Complete Rails project setup workflow. Orchestrates context → onboarding → environment → CI/CD.
  Use for new projects or when setting up development environment. Trigger: setup project,
  new rails app, configure CI/CD, dev environment setup.
keywords: rails, setup, onboarding, ci/cd, workflow, devops, configuration
---

# Rails Setup Flow — Complete Project Setup Workflow

Orchestrates the full Rails project setup from context gathering through CI/CD configuration.

## When to Use

- Starting a new Rails project
- Setting up development environment for existing project
- Configuring CI/CD pipeline
- Docker/environment setup

## Workflow Phases

### Phase 1: Context & Onboarding

**Load project context first:**
1. **skills/context/rails-context-engineering** — Understand existing codebase structure
2. **skills/context/rails-project-onboarding** — Complete dev environment setup

**HARD GATE — Environment Check:**
- Ruby version correct (check `.ruby-version`)
- Bundler installed and working
- Database connection successful
- All env vars loaded (check `config/credentials.yml.enc` or `.env`)

**If environment check FAILS:** Return to rails-project-onboarding and fix.

---

### Phase 2: CI/CD Configuration

**Proceed only after environment check passes.**

1. **CI/CD Proposal Checkpoint** — Decide on pipeline approach:
   - GitHub Actions, GitLab CI, or other platform?
   - Staging vs production environments?
   - Deployment strategy (basic, blue-green, canary)?

2. **Configure CI pipeline:**
   - Linting (RuboCop, ERBLint)
   - Testing (RSpec with coverage)
   - Security scanning (Brakeman, bundle-audit)
   - Database migrations check

3. **Configure CD pipeline:**
   - Staging deployment triggers
   - Production deployment gates
   - Rollback procedures

**Output:** `.github/workflows/ci.yml` or equivalent with complete pipeline.

---

### Phase 3: Environment Validation

**Verify everything works end-to-end:**

```bash
# Local development
bundle install
rails db:create db:migrate
rails server  # Should start without errors
bundle exec rspec  # Should run (even if 0 tests)

# CI simulation (if possible locally)
act push  # GitHub Actions local runner (optional)
```

---

## Quick Reference

```
New project?     → rails-context-engineering → rails-project-onboarding
Existing app?    → rails-context-engineering → Check setup
Need CI/CD?      → Configure GitHub Actions/GitLab CI
Not sure?        → rails-skills-orchestrator
```

## HARD-GATE: Environment Before Code

**NEVER write implementation code before:**
1. Dev environment is fully functional
2. Database connects successfully
3. Tests can run
4. CI pipeline passes basic checks

**Why:** Coding on a broken environment produces broken code.

## Output Style

**CI/CD Configuration:**
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true
      - run: bundle exec rails db:create db:migrate
      - run: bundle exec rspec
      - run: bundle exec rubocop
```

**Setup Checklist:** Marked file `SETUP_CHECKLIST.md` with:
- [ ] Ruby installed
- [ ] Bundler working
- [ ] Database created
- [ ] Tests passing
- [ ] CI configured
- [ ] Secrets configured

## Integration

| Predecessor | This Skill | Successor |
|-------------|------------|-----------|
| None (entry point) | rails-setup-flow | rails-tdd-loop (start developing) |
| None (entry point) | rails-setup-flow | create-prd (plan features first) |

**From AGENTS.md:** This is the setup workflow. For development, chain to rails-tdd-loop.
