# Extract Domain Language From User Stories

## Problem/Feature Description

The product team at FinFlow has handed over a batch of six user stories from a discovery sprint. The domain is financial transactions, loan processing, and account management. Before the engineering team begins modeling, the tech lead wants a structured **ubiquitous language glossary** extracted directly from the stories — every domain term that recurs in multiple stories, every verb that represents a command or event, and every noun that could become an entity or value object.

The stories are:

---

**Story 1 — Loan Origination**
> As a loan officer, I want to *originate* a *loan application* for a *borrower* so that the *underwriting* team can begin their *risk assessment*.

**Story 2 — Credit Scoring**
> As an underwriter, I want to retrieve the *credit score* for a *borrower* from our *bureau integration* so I can decide whether to *approve*, *decline*, or *defer* a *loan application*.

**Story 3 — Disbursement**
> As a loan officer, I want to *disburse* approved *loan funds* to the *borrower's bank account* after all *compliance checks* pass.

**Story 4 — Repayment Scheduling**
> As a borrower, I want to see my *repayment schedule* so I know when each *installment* is due, what portion is *principal*, and what portion is *interest*.

**Story 5 — Early Repayment**
> As a borrower, I want to make an *early repayment* and receive a *payoff quote* that accounts for any *prepayment penalty* applicable to my *loan product*.

**Story 6 — Default Handling**
> As a risk manager, I want to *flag* a *loan* as *defaulted* when a borrower misses more than 90 days of *scheduled payments*, and trigger a *collections workflow*.

---

## Output Specification

Produce a single Markdown file:

- `docs/ubiquitous_language.md` — The structured glossary, organized with:
  1. **Entities** — Domain objects with identity (e.g., Loan, Borrower)
  2. **Value Objects** — Immutable descriptors (e.g., CreditScore, InstallmentAmount)
  3. **Commands** — Verbs that change state (e.g., Originate, Disburse)
  4. **Domain Events** — Things that happened (e.g., LoanApproved, FundsDistributed)
  5. **Bounded Context candidates** — Groups of concepts that belong together

Each term must include: **Term**, **Definition** (in domain language, not technical jargon), and **Source Stories** (which story numbers use it).
