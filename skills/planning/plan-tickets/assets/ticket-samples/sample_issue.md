Title: Fix order total rounding error

Classification: type=Task, area=backend, execution_order=follow-up, dependency_level=unblocked, target_bucket=ready-to-refine

Description:
When applying percentage discounts to orders with multiple line items, totals are rounding inconsistently causing a mismatch between displayed total and sum of line items.

Steps to reproduce:
1. Create cart with items: A (price 199.99, qty 1), B (price 49.50, qty 2)
2. Apply discount code 'MULTI5' (5%)
3. Place order and observe total displayed vs sum of line items

Acceptance criteria:
- Add unit test reproducing mismatch
- Fix rounding logic so displayed total equals sum of adjusted line items
- Add regression spec

Estimate: 2

Labels: bug, billing

Create-in-tracker readiness:
- Draft-only until the user explicitly approves tracker creation.
- Confirm target project/board and required fields from create metadata or an equivalent field source.
- Confirm integration path and credentials outside the repo.
- Validate one issue first if field names, sprint behavior, or workflow defaults are uncertain.
- Do not set status on create; use the tracker default initial status.
