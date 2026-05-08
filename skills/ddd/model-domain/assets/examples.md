# DDD Rails Modeling Examples

## Value Object — Money

```ruby
# app/models/money.rb
class Money
  attr_reader :amount_cents, :currency

  def initialize(amount_cents, currency = "USD")
    @amount_cents = Integer(amount_cents)
    @currency = currency.upcase.freeze
    freeze
  end

  def ==(other)
    other.is_a?(Money) && amount_cents == other.amount_cents && currency == other.currency
  end

  alias eql? ==

  def hash
    [amount_cents, currency].hash
  end
end
```

- **Modeling choice:** Value object — equality by value, immutable, no database identity needed.
- **Suggested home:** `app/models/money.rb`
- **Avoid:** Adding `belongs_to` or a database table — this is a calculation value, not an entity.

## Application Service — CreateOrder

```ruby
# app/services/orders/create_order.rb
module Orders
  class CreateOrder
    Result = Struct.new(:success?, :order, :errors, keyword_init: true)

    def self.call(**args) = new(**args).call

    def initialize(user:, product_id:, quantity:)
      @user, @product_id, @quantity = user, product_id, quantity
    end

    def call
      order = @user.orders.build(product: Product.find(@product_id), quantity: @quantity)
      order.save ? Result.new(success?: true, order: order, errors: [])
                 : Result.new(success?: false, order: nil, errors: order.errors.full_messages)
    rescue ActiveRecord::RecordNotFound
      Result.new(success?: false, order: nil, errors: ["Product not found"])
    end
  end
end
```

- **Modeling choice:** Application service — coordinates persistence and follows up side effects for one use case.
- **Suggested home:** `app/services/orders/create_order.rb`
- **Avoid:** Fat controller method or a callback chain on `Order`.

## Domain Event — OrderCreated

```ruby
# app/events/orders/order_created_event.rb
module Orders
  class OrderCreatedEvent
    attr_reader :order_id, :occurred_at

    def initialize(order_id:)
      @order_id = order_id
      @occurred_at = Time.current.freeze
    end
  end
end
```

- **Modeling choice:** Domain event — record of something that happened in the domain.
- **Suggested home:** `app/events/orders/order_created_event.rb`

## JSON Mapping (Machine Readable)

```json
{
  "aggregates": [
    {
      "name": "Order",
      "model": "Order",
      "repository": "OrderRepository",
      "services": ["OrderCreator", "OrderCanceler"],
      "events": ["order.created", "order.canceled"],
      "owner": "team-orders"
    }
  ],
  "bounded_contexts": [
    {"name": "Orders", "path": "app/models/order*", "owner": "team-orders"},
    {"name": "Billing", "path": "app/services/billing/*", "owner": "team-billing"}
  ]
}
```
