# frozen_string_literal: true

class Product
  attr_accessor :id, :name, :price, :description, :errors

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v) if respond_to?("#{k}=")
    end
    @errors = {}
    @id ||= rand(1000)
  end

  def save
    # Mock save - always true for demo
    true
  end

  def self.all
    [new(name: 'Sample Product', price: 29.99, description: 'A sample product')]
  end

  def self.find(id)
    # Simulate RecordNotFound for ID 999
    if id.to_i == 999
      # Ensure ActiveRecord is available or define a shim for testing
      error_class = if defined?(ActiveRecord::RecordNotFound)
                      ActiveRecord::RecordNotFound
                    else
                      Class.new(StandardError)
                    end
      raise error_class, "Couldn't find Product with 'id'=#{id}"
    end
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
