# Workflow Execution: Product Discounting

## Problem/Feature Description

We need to implement a new feature for our `Product` model: a method `#discounted_price` that takes a percentage (0-100) and returns the price after the discount is applied. 

You must follow the **Rails TDD Loop** workflow strictly to implement this feature.

## Requirements

1.  **Initialize Workflow**: Start by loading the project context.
2.  **Test Design**: Choose the correct spec slice and write a failing RSpec test.
3.  **Validate Failure**: Run the spec and confirm it fails for the right reason (method missing).
4.  **Propose Implementation**: Describe how you will calculate the discount before writing code.
5.  **Implement**: Write the minimal code to make the test pass.
6.  **Quality & Docs**: Run linters, add YARD documentation, and perform a self-review.

## Current Project State

```ruby
# app/models/product.rb
class Product < ApplicationRecord
  # attributes: name (string), price_cents (integer)
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
end
```

## Output Specification

You must show your work as a sequence of thoughts and tool calls that mirror the **Rails TDD Loop** phases. Produce the following final artifacts:
- `spec/models/product_spec.rb` (failing first, then passing)
- `app/models/product.rb` (updated with implementation and YARD)
- Self-review notes (via `rails-code-review`)
