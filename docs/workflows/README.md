# Workflows — Rails Agent Skills

Step-by-step guides for each stage of Rails development. Each workflow is a chain of skills executed in order.

---

## Master Workflow Diagram

```mermaid
flowchart TD
    START([What do you need to do?]) --> DECISION{What stage are you at?}

    DECISION -->|New project or setup| DISCOVERY[discovery]
    DECISION -->|Plan feature| PLANNING[planning]
    DECISION -->|Configure CI/CD or environment| SETUP[setup]
    DECISION -->|Develop code| DEV[development]
    DECISION -->|Review quality| QUALITY[quality]
    DECISION -->|Code review| REVIEW[review]
    DECISION -->|Build engine| ENGINES[engines]

    DISCOVERY --> NEXT{What next?}
    PLANNING --> NEXT
    SETUP --> DEV

    NEXT -->|Implement| DEV
    NEXT -->|Done| END([PR / Merge])

    DEV -->|Tests pass| YARD[yard-documentation]
    DEV -->|Need review| REVIEW

    YARD --> REVIEW
    REVIEW -->|Feedback received| RESPOND[rails-review-response]
    RESPOND -->|Re-implement| DEV
    RESPOND -->|OK| END

    QUALITY --> REVIEW
    ENGINES --> REVIEW
```

---

## Workflow Index by Stage

| Stage | Workflow | Description | Primary Skills |
|-------|----------|-------------|----------------|
| **Discovery** | [Discovery & Context](discovery.md) | Understand codebase, project onboarding | `rails-context-engineering`, `rails-project-onboarding` |
| **Planning** | [Planning & Design](planning.md) | Plan features, PRD, tasks, DDD | `create-prd`, `generate-tasks`, `ddd-*` |
| **Setup** | [Setup & Configuration](setup.md) | Configure CI/CD, environment, deploy | `rails-project-onboarding` *(plus roadmap `rails-ci-cd-setup`)* |
| **Development** | [Development](development.md) | TDD development, implementation | `rails-tdd-slices`, `rspec-*`, implementation |
| **Quality** | [Code Quality](quality.md) | Conventions, refactoring, documentation | `rails-code-conventions`, `refactor-safely`, `yard-documentation` |
| **Review** | [Review & Validation](review.md) | Code review, security, architecture | `rails-code-review`, `rails-security-review`, `rails-architecture-review` |
| **Engines** | [Engine Development](engines.md) | Create and maintain Rails engines | `rails-engine-*` |

---

## Specialized Workflows

| Situation | Workflow | Quick Entry |
|-----------|----------|-------------|
| **Bug fix** | [Bug Fix Loop](development.md#bug-fix-loop) | `rails-bug-triage` → Fix → Test |
| **Refactoring** | [Refactor Safely](quality.md#refactor-safely) | `refactor-safely` → characterization tests → extract |
| **Performance** | [Performance Optimization](development.md#performance) | `rails-performance-optimization` |
| **GraphQL** | [GraphQL Feature](development.md#graphql) | `rails-graphql-best-practices` |
| **Authorization** | [Authorization Setup](development.md#authorization) | `rails-authorization-policies` |
| **External API** | [API Integration](development.md#external-api-integration) | `ruby-api-client-integration` |

---

## Quick Decision Tree

```
New to the project?
  ├─ Yes → rails-context-engineering → rails-project-onboarding
  └─ No → What do you need to do?

       Plan a feature?
       ├─ Yes → create-prd → generate-tasks → (ticket-planning optional)
       └─ No → Implement?

            Bug or refactor?
            ├─ Bug → rails-bug-triage
            ├─ Refactor → refactor-safely
            └─ New feature → rails-tdd-slices → rspec-best-practices

                 Code type?
                 ├─ Service → ruby-service-objects
                 ├─ REST API → ruby-api-client-integration
                 ├─ GraphQL → rails-graphql-best-practices
                 ├─ Migration → rails-migration-safety
                 ├─ Background job → rails-background-jobs
                 └─ Engine → rails-engine-author

                      Authorization/roles?
                      └─ rails-authorization-policies

                           Performance?
                           └─ rails-performance-optimization
```

---

## Cross-Cutting: Tests Gate Implementation

All code-producing workflows include this gate:

```
Write test → Run test → Verify it FAILS → Implement → Verify it PASSES
```

See details in each specific workflow.

---

## Quick Links

- [Complete Skill Catalog](../reference/skill-catalog.md)
- [Integration Matrix](../reference/integration-matrix.md)
- [Implementation Guide](../implementation-guide.md)
