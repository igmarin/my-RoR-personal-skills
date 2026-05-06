---
name: rails-engines-flow
license: MIT
description: >
  Complete Rails engine development workflow. Orchestrates scaffolding engine structure and generating
  mountable namespaces → testing → code review and dependency auditing → release.
  Use when creating, extracting, or maintaining Rails engines. Trigger: create engine,
  extract engine, engine release, engine testing, mountable engine, gem extraction.
keywords: rails, engine, workflow, gem, release, testing, extraction
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Rails Engines Flow — Complete Engine Development Workflow

Orchestrates the full lifecycle of Rails engine development from scaffolding to release.

## Workflow Phases

### Phase 1: Engine Authoring

**Scaffold and structure the engine:**
1. **skills/engines/rails-engine-author** — Design and scaffold namespace isolation, directory structure, and gemspec configuration

**Kickoff command:**
```bash
rails plugin new my_engine --mountable --skip-test
```

**Expected directory structure after scaffolding:**
```
my_engine/
  app/
  config/routes.rb
  lib/my_engine/engine.rb
  lib/my_engine/version.rb
  lib/my_engine.rb
  my_engine.gemspec
  test/dummy/
```

**HARD GATE — Engine Structure Check:**
```bash
# Verify namespace isolation
grep -r 'module MyEngine' lib/my_engine/engine.rb

# Verify gemspec metadata is complete
ruby -e "require 'rubygems'; spec = Gem::Specification.load('my_engine.gemspec'); puts spec.validate"

# Verify isolated migrations declared
grep 'isolate_namespace\|engine.config.isolate_namespace' lib/my_engine/engine.rb
```

- Proper namespace (`MyEngine::` not `::`)
- Isolated migrations and dummy app configured
- Gemspec metadata passes `gem specification` validation

**If structure check FAILS:** Return to rails-engine-author and fix.

---

### Phase 2: Testing Setup

**Proceed only after structure check passes.**

1. **skills/engines/rails-engine-testing** — Set up dummy app, spec helpers, factory isolation, and test database

2. **Write initial characterization tests:**
   - Test engine mounting
   - Test generators if any
   - Test core functionality

**Run tests from engine root:**
```bash
cd my_engine && bundle exec rspec
```

**HARD GATE — Tests Run:**
```bash
bundle exec rspec --format progress 2>&1 | tail -5
# Must show: no load errors, exit 0 or partial pass
```

---

### Phase 3: Implementation & Review

**Build engine features with quality gates:**

1. **Implement features** using:
   - rails-tdd-loop for complex features
   - Individual skills for simple additions

2. **skills/engines/rails-engine-reviewer** — Coupling assessment, API surface design, host app integration points

3. **skills/engines/rails-engine-compatibility** — Rails/Ruby version matrix and dependency constraints

**Check gem dependencies:**
```bash
bundle exec rake dependencies
bundle exec bundler-audit check --update
```

---

### Phase 4: Documentation & Release

**Prepare for publication:**

1. **skills/engines/rails-engine-docs** — Installation, configuration, usage examples, changelog

2. **skills/engines/rails-engine-release** — Version bump (SemVer), changelog, upgrade notes, git tag

**Release commands:**
```bash
gem build my_engine.gemspec
gem push my_engine-1.0.0.gem
git tag v1.0.0 && git push origin v1.0.0
```

**Optional:**
3. **skills/engines/rails-engine-installers** — Idempotent `rails g my_engine:install` generator for host app configuration

**Output:** Published gem or releasable GitHub repository.

---

## Quick Reference

```
New engine?        → rails-engine-author → rails-engine-testing
Extract from app?  → rails-engine-extraction → rails-engine-author
Release engine?    → rails-engine-reviewer → rails-engine-release
Not sure?          → rails-skills-orchestrator
```

## HARD-GATE: Isolation Before Integration

**NEVER integrate engine into host app before:**
1. Engine tests pass standalone
2. Namespace properly isolated
3. Migrations won't conflict
4. Dependencies clearly declared

## Output Style

**Engine Release Checklist (abbreviated):**
```markdown
# Engine Release — v1.0.0
- [x] Namespace isolation: MyEngine::
- [x] Test suite: passing
- [x] README and Changelog updated
- [x] Git tag: v1.0.0
```

## Integration

| Predecessor | This Skill | Successor |
|-------------|------------|-----------|
| create-prd (engine requirements) | rails-engines-flow | rails-tdd-loop (engine features) |
| None (extract existing) | rails-engines-flow | Host app integration |

**From AGENTS.md:** This is the engine development workflow. Chain to rails-tdd-loop for feature development within the engine.
