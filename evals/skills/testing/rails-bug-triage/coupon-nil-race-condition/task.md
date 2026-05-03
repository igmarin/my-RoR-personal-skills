# Triage a Flaky Checkout Flow Bug

## Problem/Feature Description

A QA engineer has filed the following bug report:

---

**Bug #4217 — Intermittent `NoMethodError` in checkout flow**

**Environment:** Production, Rails 7.1, Ruby 3.2

**Steps to reproduce:**
1. Add two or more items to cart
2. Proceed to checkout
3. Apply a coupon code (any code starting with `SAVE`)
4. Click "Place Order"

**Observed behavior:**
Approximately 30% of the time, the order creation fails with:

```
NoMethodError: undefined method `discount_cents' for nil
  app/services/orders/create_order_service.rb:47:in `apply_discount'
  app/services/orders/create_order_service.rb:31:in `call'
  app/controllers/orders_controller.rb:22:in `create'
```

**Expected behavior:** Order is placed successfully and the coupon discount is applied.

**Additional notes:** The bug does not reproduce when running the feature spec locally. It only appears under load, suggesting a race condition or missing guard.

---

The following source files are provided. Extract them before beginning.

=============== FILE: app/services/orders/create_order_service.rb ===============
# frozen_string_literal: true

module Orders
  class CreateOrderService
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @user    = params[:user]
      @cart    = params[:cart]
      @coupon_code = params[:coupon_code]
    end

    def call
      validate!
      coupon = Coupon.find_by(code: @coupon_code)
      order  = Order.create!(user: @user, total_cents: @cart.total_cents)
      apply_discount(order, coupon)
      { success: true, response: { order: order } }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, response: { error: { message: e.message } } }
    end

    private

    def validate!
      raise ArgumentError, "user is required" unless @user
      raise ArgumentError, "cart is required" unless @cart
    end

    def apply_discount(order, coupon)
      return unless @coupon_code.present?

      order.update!(discount_cents: coupon.discount_cents)
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

1. `spec/services/orders/create_order_service_spec.rb` — A failing RSpec spec that **reproduces the bug** (the test must fail before the fix is applied)
2. `app/services/orders/create_order_service.rb` — The fixed version of the service with the bug corrected and a brief inline comment explaining the root cause

Do not add unrelated features. The fix must be minimal.
