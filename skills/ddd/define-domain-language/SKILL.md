---
name: define-domain-language
license: MIT
description: >
  Use when a Ruby on Rails feature, bug, or architecture discussion has fuzzy
  business terminology and you need shared vocabulary. Identifies canonical terms,
  resolves naming conflicts, maps synonyms to one concept, and generates a glossary
  for Rails-first workflows. Trigger words: DDD, shared vocabulary, define terms,
  bounded context naming, what should we call this, terminology alignment, DDD glossary,
  naming inconsistency.
metadata:
  version: 1.1.0
  user-invocable: "true"
---
# Define Domain Language

Use this skill when the domain language is fuzzy, overloaded, or inconsistent.

**Core principle:** Agree on business language before choosing models, services, or boundaries.

## Quick Reference

| Topic | Rule |
|-------|------|
| Canonical term | Pick one business term for one concept |
| Synonyms | Capture them, then choose one preferred term |
| Overloaded words | Flag them early; split meanings explicitly |
| Naming | Prefer business meaning over technical shorthand |
| Output | Return a usable glossary, not abstract theory |

## HARD-GATE

```text
DO NOT introduce DDD terminology without grounding it in the user's real domain language.
DO NOT rename code concepts until the glossary is explicit enough to justify the change.
ALWAYS flag overloaded or conflicting terms before recommending modeling changes.
```

## When to Use

- The user uses multiple words for what might be the same business concept.
- A feature or bug discussion is blocked by unclear naming.
- You need a glossary before doing boundary review or Rails modeling.
- **Next step:** Chain to `review-domain-boundaries` when the glossary reveals multiple contexts, or to `model-domain` when the main problem is tactical modeling in Rails.

## Process

1. **Collect terms:** Pull candidate nouns, roles, states, events, and actions from the request, PRD, tickets, existing docs, and code names. In a Rails codebase, scan class and file names across layers:
   ```bash
   grep -rh "^class \|^module " app/models app/controllers app/services --include="*.rb" | sort
   ```
2. **Group synonyms:** Identify words that appear to mean the same thing and words that are overloaded across multiple meanings.
3. **Choose canonical terms:** Prefer the clearest business term; keep aliases only as migration notes or search hints.
4. **Define each term:** Write one short definition, expected invariants, and related concepts.
5. **Flag ambiguity:** List terms that need user confirmation or that likely indicate multiple bounded contexts.
6. **Hand off:** Continue with `review-domain-boundaries`, `model-domain`, or `create-prd` / `generate-tasks` depending on the workflow stage.

### Worked Example: Customer/Client/Account Resolution

**Scenario:** The codebase uses `Customer` in the storefront, `Client` in the billing reports, and `Account` in the admin dashboard—all referring to the same entity.

**Step 1: Collect terms**
- `Customer` (StorefrontController, CustomerMailer)
- `Client` (BillingReport, ClientInvoice)
- `Account` (Admin::AccountsController, AccountSettings)

**Step 2: Group synonyms**
All three appear to represent the same business concept: a person or organization that buys from us.

**Step 3: Choose canonical term**
Business stakeholders say "Customer" in meetings and requirements docs. The billing team uses "Client" only because their legacy system did. Admin uses "Account" as a legacy shortcut.

**Decision:** Canonical term = **Customer**
Aliases to capture: Client, Account

**Step 4: Define with invariants**

| Canonical term | Aliases | Definition | Invariant | Context |
|----------------|---------|------------|-----------|---------|
| Customer | Client, Account | A person or organization that purchases goods/services from our platform | Must have a unique email; can have zero or more Orders | Sales & Billing |

**Step 5: Flag ambiguity**
- **Open question:** Does "Account" ever refer to the login credentials entity (separate from the customer profile)? If yes, split into two entries.
- **Open question:** Does "Client" mean something different in the legal/contracts module?

**Step 6: Migration path**
- Update code comments and docs to use "Customer"
- Rename `ClientInvoice` → `CustomerInvoice` (single PR)
- Add aliases in search/indexing for backward compatibility
- Do NOT rename database tables yet—wait for glossary stabilization

## Output Style

When using this skill, return:

1. **Canonical term**
2. **Aliases / conflicting words**
3. **Definition**
4. **Key invariant or business rule**
5. **Likely related context**
6. **Open questions**

**Minimal example (one row):**

| Canonical term | Aliases | Definition | Invariant | Context |
|----------------|---------|------------|-----------|----------|
| Shipment | Parcel, Package | Physical goods sent to a customer address | Must reference a valid Order | Fulfillment |

**Open questions:** Does "Parcel" ever mean an internal warehouse bin ID? If yes, split into two glossary entries.

See [assets/examples.md](assets/examples.md) for a full worked glossary example and common mistakes.

## Integration

| Skill | When to chain |
|-------|---------------|
| **create-prd** | When a PRD needs cleaner business language before approval |
| **review-domain-boundaries** | When the glossary suggests multiple bounded contexts or language leakage |
| **model-domain** | When the terms are clear enough to decide entities, value objects, and services |
| **review-architecture** | When naming confusion already appears in the code structure |

## Assets & Examples

Two complementary example resources are provided:

- **[EXAMPLES.md](EXAMPLES.md)** — Full worked scenarios showing input tickets/PRDs, the resolution process, and common mistakes (best for understanding the workflow)
- **[assets/examples.md](assets/examples.md)** — JSON schema examples for glossary entries and validation patterns (best for technical implementation)
