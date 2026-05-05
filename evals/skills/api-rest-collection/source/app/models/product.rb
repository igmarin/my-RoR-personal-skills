# frozen_string_literal: true

class Product
  attr_accessor :id, :name, :price, :description, :errors

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
    @errors = {}
    @id = rand(1000)
  end

  def save
    # Mock save - always true for demo
    true
  end

  def self.all
    [new(name: 'Sample Product', price: 29.99, description: 'A sample product')]
  end

  def self.find(id)
    new(id: id, name: 'Sample Product', price: 29.99)
  end

  def update(attributes)
    attributes.each do |k, v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
    true
  end

  def destroy
    true
  end
end
