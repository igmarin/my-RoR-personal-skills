# Bug Triage: Intermittent Data Leak

## Problem/Feature Description

A user has reported a critical bug: "Sometimes, when I refresh my dashboard, I briefly see data belonging to another account before it switches back to mine." This suggests a potential race condition or a scope-leaking issue in the `DashboardController`.

Your task is to perform a **Bug Triage** to reproduce, isolate, and fix this issue.

## Current Code

```ruby
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Potential leak here?
    @stats = AccountStats.fetch_for(params[:account_id])
    render json: @stats
  end
end

class AccountStats
  def self.fetch_for(account_id)
    # This caches stats in a class variable for performance
    @@cached_stats ||= {}
    @@cached_stats[account_id] ||= calculate_complex_stats(account_id)
  end
end
```

## Requirements

1.  **Reproduction Spec**: Write a failing RSpec test (request or controller spec) that demonstrates the data leak between two concurrent users.
2.  **Isolate**: Identify the exact line/pattern causing the leak.
3.  **Fix Plan**: Propose a fix that ensures data isolation (e.g., removing class-level caching or using thread-safe storage).
4.  **Verification**: Confirm the spec passes after the fix is applied.

## Output Specification

Produce the following:
- `spec/requests/dashboard_api_spec.rb` (the failing reproduction spec)
- A brief diagnostic report identifying the root cause.
- The fixed `AccountStats` class implementation.
