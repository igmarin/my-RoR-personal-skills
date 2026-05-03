# Write Tests for the ShippingRates Engine

## Problem/Feature Description

The `ShippingRates` engine (first seen in the rails-engine-docs eval) needs a test suite before it can be released. The team wants a dummy Rails app and RSpec tests set up following the `rails-engine-testing` patterns.

The engine's public API is reproduced below. Extract it before beginning.

=============== FILE: lib/shipping_rates/calculator.rb ===============
# frozen_string_literal: true

module ShippingRates
  class Calculator
    CARRIERS = %w[ups fedex usps].freeze

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @origin      = params.fetch(:origin)
      @destination = params.fetch(:destination)
      @weight_oz   = params.fetch(:weight_oz)
      @carrier     = params.fetch(:carrier, 'ups')
    end

    def call
      validate!
      rate = fetch_rate
      { success: true, response: { carrier: @carrier, rate_cents: rate } }
    rescue ArgumentError => e
      { success: false, response: { error: { message: e.message } } }
    end

    private

    def validate!
      raise ArgumentError, "Unsupported carrier: #{@carrier}" unless CARRIERS.include?(@carrier)
      raise ArgumentError, "weight_oz must be positive" unless @weight_oz.positive?
    end

    def fetch_rate
      (@weight_oz * 0.05 * 100).round
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `spec/shipping_rates/calculator_spec.rb` — RSpec spec for the Calculator service covering:
  - Successful call with each supported carrier
  - Unsupported carrier returns error response
  - Zero or negative weight returns error response
  - Default carrier is 'ups'
  - Response shape validation (`:success`, `:response`, `:carrier`, `:rate_cents` keys present)
- `spec/spec_helper.rb` — Minimal spec helper that loads the engine (no Rails dummy app required for a pure Ruby engine)
