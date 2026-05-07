# DDD Modeling: Logistics & Shipments

## Problem/Feature Description

Our e-commerce platform needs a more robust way to handle shipping logistics. Currently, shipping addresses and carrier logic are mixed into a "fat" `Order` model. 

Your task is to model this domain using **DDD Rails Modeling** principles. We need to separate the concepts into Entities, Value Objects, and Domain Services without fighting Rails conventions.

## Requirements

1.  Model `Address` as a **Value Object** (stateless, immutable PORO).
2.  Model `Shipment` as an **Entity/Aggregate** (ActiveRecord model).
3.  Implement a **Domain Service** `Shipping::CarrierSelector` to pick the best carrier based on weight and destination.
4.  Ensure `Address` handling in the `Shipment` model uses Rails' `composed_of` or a similar idiomatic pattern.
5.  Avoid logic leakage: The `Order` model should not know how to calculate shipping costs.

## Current State

```ruby
# Current messy logic in Order
class Order < ApplicationRecord
  # attributes: street, city, zip, country, weight_kg
  
  def shipping_cost
    if country == 'US'
      weight_kg * 5
    else
      weight_kg * 15
    end
  end
end
```

## Output Specification

Produce the following files:
- `app/models/shipping/address.rb` (Value Object)
- `app/models/shipping/shipment.rb` (Entity)
- `app/services/shipping/carrier_selector.rb` (Domain Service)
- A brief explanation of the domain boundaries chosen.
