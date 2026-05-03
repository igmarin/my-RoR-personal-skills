#!/bin/bash

# Ensure parent directories exist
mkdir -p evals/skills/infrastructure/rails-api-versioning
mkdir -p evals/skills/code-quality/rails-architecture-review
mkdir -p evals/skills/code-quality/rails-authorization-policies
mkdir -p evals/skills/infrastructure/rails-background-jobs
mkdir -p evals/skills/patterns/ruby-service-objects
mkdir -p evals/skills/code-quality/refactor-safely
mkdir -p evals/skills/api/ruby-api-client-integration
mkdir -p evals/skills/code-quality/rails-code-conventions
mkdir -p evals/skills/code-quality/rails-stack-conventions
mkdir -p evals/skills/infrastructure/rails-migration-safety
mkdir -p evals/skills/ddd/ddd-rails-modeling
mkdir -p evals/skills/engines/rails-engine-release
mkdir -p evals/skills/testing/rspec-best-practices
mkdir -p evals/skills/api/rails-graphql-best-practices
mkdir -p evals/skills/infrastructure/rails-performance-optimization
mkdir -p evals/skills/planning/create-prd
mkdir -p evals/skills/engines/rails-engine-author
mkdir -p evals/skills/api/api-rest-collection
mkdir -p evals/skills/code-quality/rails-code-review
mkdir -p evals/skills/code-quality/rails-security-review
mkdir -p evals/skills/ddd/ddd-boundaries-review
mkdir -p evals/skills/patterns/strategy-factory-null-calculator
mkdir -p evals/skills/testing/rails-tdd-slices
mkdir -p evals/skills/planning/generate-tasks
mkdir -p evals/workflows/rails-tdd-loop
mkdir -p evals/skills/planning/ticket-planning
mkdir -p evals/skills/patterns/yard-documentation

git mv evals/api-versioning-with-controller-inheritan evals/skills/infrastructure/rails-api-versioning/
git mv evals/architecture-review-methodology-and-seve evals/skills/code-quality/rails-architecture-review/
git mv evals/authorization-anti-patterns-and-request- evals/skills/code-quality/rails-authorization-policies/
git mv evals/background-job-idempotency-and-retry-str evals/skills/infrastructure/rails-background-jobs/
git mv evals/call-pattern-and-response-format evals/skills/patterns/ruby-service-objects/
git mv evals/cancancan-ability-class-and-index-query- evals/skills/code-quality/rails-authorization-policies/
git mv evals/characterization-tests-and-step-verifica evals/skills/code-quality/refactor-safely/
git mv evals/client-error-handling-and-credentials evals/skills/api/ruby-api-client-integration/
git mv evals/comment-conventions-and-tagged-notes evals/skills/code-quality/rails-code-conventions/
git mv evals/constants-documentation-and-class-only-s evals/skills/code-quality/rails-stack-conventions/
git mv evals/database-safety-and-module-structure evals/skills/infrastructure/rails-migration-safety/
git mv evals/domain-entity-and-builder-patterns evals/skills/ddd/ddd-rails-modeling/
git mv evals/engine-gem-release-discipline-and-change evals/skills/engines/rails-engine-release/
git mv evals/error-handling-and-input-validation evals/skills/patterns/ruby-service-objects/
git mv evals/factory-minimalism-and-external-boundary evals/skills/testing/rspec-best-practices/
git mv evals/graphql-n-1-prevention-field-auth-and-mu evals/skills/api/rails-graphql-best-practices/
git mv evals/layered-api-client-structure evals/skills/api/ruby-api-client-integration/
git mv evals/performance-baseline-measurement-and-reg evals/skills/infrastructure/rails-performance-optimization/
git mv evals/prd-structure-and-content-discipline evals/skills/planning/create-prd/
git mv evals/pundit-policy-objects-and-multi-role-tes evals/skills/code-quality/rails-authorization-policies/
git mv evals/rails-engine-structure-isolation-and-hos evals/skills/engines/rails-engine-author/
git mv evals/rest-api-collection-generation evals/skills/api/api-rest-collection/
git mv evals/review-order-severity-classification-and evals/skills/code-quality/rails-code-review/
git mv evals/rspec-structure-naming-and-file-conventi evals/skills/testing/rspec-best-practices/
git mv evals/security-review-methodology-and-severity evals/skills/code-quality/rails-security-review/
git mv evals/service-decomposition-and-boundaries evals/skills/ddd/ddd-boundaries-review/
git mv evals/service-map-factory-dispatch-and-null-ob evals/skills/patterns/strategy-factory-null-calculator/
git mv evals/shared-examples-and-time-dependent-spec- evals/skills/testing/rspec-best-practices/
git mv evals/spec-type-selection-by-behavior-layer evals/skills/testing/rails-tdd-slices/
git mv evals/sql-security-with-dynamic-queries evals/skills/code-quality/rails-security-review/
git mv evals/structured-logging-format evals/skills/code-quality/rails-stack-conventions/
git mv evals/task-list-generation-with-tdd-structure- evals/skills/planning/generate-tasks/
git mv evals/tdd-workflow-and-test-first-discipline evals/workflows/rails-tdd-loop/
git mv evals/ticket-classification-attributes-and-sta evals/skills/planning/ticket-planning/
git mv evals/yard-documentation-tags-and-completeness evals/skills/patterns/yard-documentation/

