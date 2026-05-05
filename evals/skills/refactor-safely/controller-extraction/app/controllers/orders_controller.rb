# frozen_string_literal: true

require_relative 'application_controller'
require_relative '../models/order'

class OrdersController < ApplicationController
  def create
    product_id = params[:product_id]
    quantity = params[:quantity].to_i

    if product_id.nil? || quantity <= 0
      render json: { error: 'Invalid product or quantity' }, status: 400
      return
    end

    # 1. Check inventory (Mocked call)
    inventory_available = check_inventory(product_id, quantity)

    unless inventory_available
      render json: { error: 'Not enough inventory' }, status: 422
      return
    end

    # 2. Calculate prices
    base_price = get_base_price(product_id)
    subtotal = base_price * quantity

    # 3. Calculate taxes (Mocked 10% tax rate for simplicity)
    tax = subtotal * 0.10

    # 4. Calculate shipping (Flat rate $5, free over $50)
    shipping = subtotal > 50 ? 0.0 : 5.0

    total_price = subtotal + tax + shipping

    # 5. Create order in database
    order = Order.new(
      product_id: product_id,
      quantity: quantity,
      total_price: total_price,
      tax: tax,
      shipping: shipping
    )

    if order.save
      # 6. Send confirmation email (Mocked call)
      send_confirmation_email(order)

      render json: {
        message: 'Order created successfully',
        order: { id: order.id, total_price: total_price, status: order.status }
      }, status: 201
    else
      render json: { error: 'Failed to create order' }, status: 500
    end
  end

  private

  def check_inventory(product_id, quantity)
    # Mocking inventory logic. Let's say product 'p_123' always has inventory, others might not.
    product_id == 'p_123' && quantity <= 10
  end

  def get_base_price(_product_id)
    # Mock base price
    15.0
  end

  def send_confirmation_email(order)
    # Mock email sending
    # puts "Sending email for order #{order.id}"
  end
end
