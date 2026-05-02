---
name: rails-engines-flow
license: MIT
description: >
  Complete Rails engine development workflow. Orchestrates authoring → testing → review → release.
  Use when creating, extracting, or maintaining Rails engines. Trigger: create engine,
  extract engine, engine release, engine testing.
keywords: rails, engine, workflow, gem, release, testing, extraction
---

# Rails Engines Flow — Complete Engine Development Workflow

Orchestrates the full lifecycle of Rails engine development from scaffolding to release.

## When to Use

- Creating a new Rails engine
- Extracting code from host app to engine
- Preparing engine for release
- Reviewing engine architecture

## Workflow Phases

### Phase 1: Engine Authoring

**Scaffold and structure the engine:**
1. **skills/engines/rails-engine-author** — Design and scaffold
   - Namespace isolation
   - Directory structure
   - Initial gemspec configuration

**HARD GATE — Engine Structure Check:**
- Proper namespace (e.g., `MyEngine::` not `::`)
- Isolated migrations
- Dummy app configured
- Gemspec metadata complete

**If structure check FAILS:** Return to rails-engine-author and fix.

---

### Phase 2: Testing Setup

**Proceed only after structure check passes.**

1. **skills/engines/rails-engine-testing** — Set up test infrastructure
   - Dummy app for testing
   - Engine-specific spec helpers
   - Factories isolation
   - Test database configuration

2. **Write initial characterization tests:**
   - Test engine mounting
   - Test generators if any
   - Test core functionality

**HARD GATE — Tests Run:**
- `bundle exec rspec` executes in engine directory
- At least one test passes (engine loads)
- No load path issues

---

### Phase 3: Implementation & Review

**Build engine features with quality gates:**

1. **Implement features** using:
   - rails-tdd-loop for complex features
   - Individual skills for simple additions

2. **skills/engines/rails-engine-reviewer** — Architecture review
   - Coupling assessment
   - API surface design
   - Host app integration points

3. **skills/engines/rails-engine-compatibility** — Version matrix
   - Rails version compatibility
   - Ruby version support
   - Dependency constraints

---

### Phase 4: Documentation & Release

**Prepare for publication:**

1. **skills/engines/rails-engine-docs** — Comprehensive documentation
   - Installation instructions
   - Configuration guide
   - Usage examples
   - Changelog

2. **skills/engines/rails-engine-release** — Versioned release
   - Version bump (follow SemVer)
   - Changelog updates
   - Upgrade notes
   - Git tag creation

**Optional:**
3. **skills/engines/rails-engine-installers** — Idempotent install generator
   - `rails g my_engine:install` works
   - Host app configuration automated

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

**Why:** Poorly isolated engines create coupling nightmares.

## Output Style

**Engine Release Checklist:**
```markdown
# Engine Release — v1.0.0

## Structure
- [x] Namespace isolation: MyEngine::
- [x] Dummy app: Configured
- [x] Migrations: Isolated and reversible

## Testing
- [x] Test suite: 42 tests, all passing
- [x] Compatibility: Rails 7.0, 7.1; Ruby 3.1, 3.2

## Documentation
- [x] README: Installation, usage, examples
- [x] Changelog: v1.0.0 changes documented
- [x] Upgrade notes: N/A (initial release)

## Release
- [x] Version bumped in gemspec
- [x] Git tag: v1.0.0
- [x] Pushed to RubyGems (if public)
```

## Integration

| Predecessor | This Skill | Successor |
|-------------|------------|-----------|
| create-prd (engine requirements) | rails-engines-flow | rails-tdd-loop (engine features) |
| None (extract existing) | rails-engines-flow | Host app integration |

**From AGENTS.md:** This is the engine development workflow. Chain to rails-tdd-loop for feature development within the engine.
