---
name: rails-engine-release
description: Prepare Ruby on Rails engines for release and versioned delivery. Use when updating a gemspec, planning a release, writing changelog entries, handling deprecations, setting semantic versions, or preparing migration and upgrade notes for an engine.
---
# Rails Engine Release

Use this skill when the task is to ship a Rails engine as a gem or prepare a new version.

Release work should make upgrades predictable for host applications.

## Release Order

1. Confirm the scope of change.
2. Classify compatibility impact.
3. Set the version bump.
4. Update changelog and upgrade notes.
5. Verify gemspec metadata and dependencies.
6. Confirm tests and installation docs match the release.

## Versioning Rules

- Patch: bug fixes and internal changes without public behavior breakage.
- Minor: backward-compatible features and new extension points.
- Major: breaking changes to API, setup, routes, migrations, configuration, or supported framework versions.

If the engine requires host changes during upgrade, document them explicitly even if the version bump is minor.

## Release Checklist

- gemspec metadata is current
- version constant updated once
- changelog reflects user-visible changes
- deprecations documented with removal plan
- migration or install changes called out
- README/setup instructions still accurate

## Upgrade Notes Should Include

- required host code changes
- migration steps
- configuration additions or removals
- compatibility changes for Rails/Ruby versions
- deprecation replacements

## Review Triggers

- silent breaking changes
- missing upgrade notes for migrations or configuration changes
- gemspec constraints inconsistent with tested versions
- changelog written from implementation details instead of user impact

## Output Style

When asked to prepare a release:

1. Recommend the version bump and why.
2. Draft concise changelog entries.
3. Draft upgrade notes for host apps.
4. Call out any release blockers clearly.
