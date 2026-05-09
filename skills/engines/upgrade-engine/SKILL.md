---
name: upgrade-engine
license: MIT
description: >
  Use when making a Rails engine stable across Rails and Ruby versions. Configures
  Zeitwerk autoloading, updates gemspec dependency bounds, replaces Rails.version
  branching with feature detection patterns, and sets up CI matrices for cross-version
  testing. Trigger words: Zeitwerk, autoloading, Rails upgrade, gemspec, dependency
  bounds, CI matrix, feature detection, reload safety, deprecated APIs, cross-version.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Upgrade Engine

**Core principle:** Every claimed Rails/Ruby version must be in the CI matrix. Prefer explicit support targets over accidental compatibility.

## HARD-GATE

```
Before claiming support for a Rails/Ruby version:
  1. bundle exec rake zeitwerk:check        # verify autoloading on each version
  2. bundle exec rspec                       # full suite per matrix version
  3. CI matrix must pass — not just main Rails version

DO NOT ship compatibility changes without verifying both autoloading and full suite.
```

## Quick Reference

| Compatibility Aspect | Check |
|----------------------|-------|
| Zeitwerk | File paths match constant names; no anonymous or root-level constants |
| Gemspec bounds | `add_dependency` and `required_ruby_version` match tested versions |
| Feature detection | Use `respond_to?`, `defined?`, or adapter seams instead of `Rails.version` |
| Test matrix | CI runs against each claimed Rails/Ruby combination |

## Core Checks

1. Define supported Ruby and Rails versions — state them in gemspec and README.
2. Run `bundle exec rake zeitwerk:check` — file paths must match constant names exactly.
3. Check initializer behavior across boot and reload — use `config.to_prepare` for reload-sensitive hooks.
4. Verify gemspec dependency bounds match tested versions: `spec.add_dependency "rails", ">= 7.0", "< 8.0"` — bounds must match what CI actually tests.
5. Check optional integrations (jobs, mailers, assets, routes) per version.
6. CI matrix must run against each claimed Rails/Ruby combination:

```yaml
strategy:
  matrix:
    include:
      - { ruby: "3.2", rails: "7.1" }
      - { ruby: "3.3", rails: "7.2" }
```

## Pitfalls

| Problem | Correct approach |
|---------|------------------|
| `Rails.version` branching | Use `respond_to?`, `defined?`, or adapter seams — version checks are brittle |
| Zeitwerk file/constant mismatch | File path must mirror constant name exactly — `my_engine/widget_policy.rb` → `MyEngine::WidgetPolicy` |
| Broad gemspec constraints without CI | Claiming `>= 5.2` without testing 5.2/6.x is silent incompatibility |
| No version bounds in gemspec | Unbounded constraints allow breaking upgrades into the engine |
| Reload-unsafe hooks at load time | Move to `config.to_prepare` — it runs on each reload in development |
| Tests only on one Rails version | CI matrix required before claiming multi-version support |

## Key Example: Feature Detection

```ruby
# ❌ Bad — brittle, wrong for patch versions
if Rails.version >= "7.0"
  config.active_support.cache_format_version = 7.0
end

# ✅ Good — detect the capability directly
if ActiveSupport::Cache.respond_to?(:format_version=)
  config.active_support.cache_format_version = 7.0
end
```

If an EXAMPLES.md is present in the repository, consult it for additional patterns covering gemspec bounds, Zeitwerk file/constant naming, reload-safe hooks, and CI matrix YAML. If not, the Pitfalls table and Key Example above cover the most common cases.

## Output Style

When asked to improve compatibility:

1. State the support matrix being targeted.
2. List the most likely breakpoints.
3. Make compatibility changes in isolated, testable seams.
4. Recommend matrix coverage if it does not exist.

## Integration

| Skill | When to chain |
|-------|----------------|
| test-engine | Test matrix setup, CI configuration, multi-version tests |
| create-engine | Engine structure, host contract, namespace design |
| release-engine | Versioning, changelog, upgrade notes for compatibility changes |

## Assets

The following supplementary files may be present in the repository. Consult them if available; the skill body above is self-contained if they are not.

- [assets/compatibility_matrix.md](assets/compatibility_matrix.md) — version support matrix template
- [assets/zeitwerk_notes.md](assets/zeitwerk_notes.md) — extended Zeitwerk naming and configuration notes


## Extended Resources

- [EXAMPLES.md](EXAMPLES.md)
