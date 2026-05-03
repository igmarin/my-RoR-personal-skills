# Write README for a Rails Engine: `ShippingRates`

## Problem/Feature Description

The `ShippingRates` Rails engine is ready for its first release as an open-source gem. Before publishing, the team needs complete documentation written in the style prescribed by the `rails-engine-docs` skill: a `README.md` for the gem repository, plus inline YARD documentation for the engine's main public class.

The engine's public API is provided below. Extract it before beginning.

=============== FILE: lib/shipping_rates/engine.rb ===============
# frozen_string_literal: true

module ShippingRates
  class Engine < ::Rails::Engine
    isolate_namespace ShippingRates
  end
end
=============== END FILE ===============

=============== FILE: lib/shipping_rates/calculator.rb ===============
# frozen_string_literal: true

module ShippingRates
  class Calculator
    CARRIERS = %w[ups fedex usps].freeze

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @origin      = params.fetch(:origin)       # { city:, state:, zip: }
      @destination = params.fetch(:destination)  # { city:, state:, zip: }
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
      # Placeholder: calls external carrier API
      (@weight_oz * 0.05 * 100).round
    end
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `README.md` — Full gem README with: installation, configuration, usage example, supported carriers, return shape, error handling, and contributing section
- `lib/shipping_rates/calculator.rb` — Same file with YARD documentation added to all public surfaces (class, `self.call`, `initialize`) — do not change logic
