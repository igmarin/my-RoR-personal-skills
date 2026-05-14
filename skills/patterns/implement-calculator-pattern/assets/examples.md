# implement-calculator-pattern examples

1) Factory usage example (Ruby)

```ruby
calculator = StrategyFactory.for(account: account)
result = calculator.calculate(amount: 1000)
```

2) Null calculator behavior

NullCalculator returns zeroed results and never raises, safe to use as fallback:

```
{ value: 0, breakdown: {}, warnings: [] }
```

3) Lookup order
- The factory tries strategies in `lookup_order` and falls back to `null_calculator` if none match.

1) Required verification shape
- Factory, BaseService, NullService, and concrete services each get their own RED command and GREEN checkpoint.
- Concrete services mirror contexts for named variant, inactive plan, nil plan, and unknown variant when applicable.
- BaseService raises `NotImplementedError, "#{self.class}#compute_result must be implemented"` until a concrete service implements the calculation.
