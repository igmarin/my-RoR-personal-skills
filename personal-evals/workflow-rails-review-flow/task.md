# Workflow: Systematic PR Review

## Problem/Feature Description

You have been assigned a Pull Request to review. The PR implements a new "Premium Search" feature. It includes a controller, a search service, and a migration.

Your task is to execute the **Rails Review Flow** to provide a Senior-level code review.

## The Pull Request Content

### 1. Migration
```ruby
class AddIndexToProducts < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :search_vector # Missing algorithm: concurrently?
  end
end
```

### 2. Controller
```ruby
class SearchController < ApplicationController
  def index
    # N+1 alert: products don't include images
    @products = Product.where("name ILIKE ?", "%#{params[:q]}%").limit(20)
    render json: @products
  end
end
```

### 3. Service
```ruby
class SearchService
  def self.call(query)
    # Security: raw SQL injection?
    ActiveRecord::Base.connection.execute("SELECT * FROM products WHERE name = '#{query}'")
  end
end
```

## Requirements

1.  **Multi-Pass Review**: Perform a systematic review (Security, Performance, Conventions).
2.  **Severity Classification**: Categorize findings as **Critical**, **Suggestion**, or **Nice-to-have**.
3.  **Actionable Feedback**: Provide specific code corrections for the findings.
4.  **Orchestration**: Show the transition through the review phases defined in the workflow.

## Output Specification

Produce a complete review report with:
- Summary of findings.
- Detailed comments per file with severity.
- Recommended fixes.
