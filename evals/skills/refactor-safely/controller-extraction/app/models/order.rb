# frozen_string_literal: true

class Order
  attr_accessor :product_id, :quantity, :total_price, :status, :tax, :shipping

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
    @status ||= 'pending'
  end

  def save
    # Mock save behavior
    @id = rand(1000)
    true
  end

  attr_reader :id

  def self.create(attributes = {})
    order = new(attributes)
    order.save
    order
  end
end
