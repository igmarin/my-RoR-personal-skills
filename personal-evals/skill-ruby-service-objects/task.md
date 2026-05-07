# Service Object Refactoring: Order Placement

## Problem/Feature Description

The `OrdersController#create` action in our legacy Rails application has become a "fat controller." It handles validation, payment processing via an external gateway, inventory management, and notifications all in a single block. This makes it difficult to test and maintain.

Your task is to refactor this logic into a production-grade Service Object following our **Ruby Service Objects** conventions.

## Legacy Controller Code

```ruby
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    
    # 1. Validation
    if @order.items.empty?
      render json: { error: "Order must have items" }, status: :unprocessable_entity
      return
    end

    # 2. Payment Processing
    payment_result = StripeClient.charge(amount: @order.total_price, token: params[:stripe_token])
    unless payment_result[:success]
      render json: { error: "Payment failed: #{payment_result[:error]}" }, status: :payment_required
      return
    end

    # 3. Inventory Update
    ActiveRecord::Base.transaction do
      @order.save!
      @order.items.each do |item|
        product = Product.find(item.product_id)
        if product.stock < item.quantity
          raise "Insufficient stock for #{product.name}"
        end
        product.decrement!(:stock, item.quantity)
      end
    end

    # 4. Notifications
    OrderMailer.confirmation(@order).deliver_later
    
    render json: { success: true, order: @order }, status: :created
  rescue => e
    render json: { error: "Order placement failed: #{e.message}" }, status: :internal_server_error
  end
end
```

## Requirements

1.  Extract the logic into `Orders::PlacementService`.
2.  Follow the **.call** pattern (Pattern 1 in our guide).
3.  Ensure the service returns the **MANDATORY Response Contract**: `{ success: bool, response: Hash }`.
4.  Implement **YARD documentation** for `self.call` and `#call`.
5.  Extract user-facing error messages into **constants**.
6.  Create a **Module README** for the `Orders` module.
7.  Ensure **TDD discipline**: Create the failing spec before the implementation.

## Output Specification

Produce the following files:
- `app/services/orders/placement_service.rb`
- `app/services/orders/README.md`
- `spec/services/orders/placement_service_spec.rb`

Do not modify the controller in this task; just provide the service and its supporting files.
