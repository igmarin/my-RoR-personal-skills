# Ensure the ShippingRates Engine Works Across Rails 7.0, 7.1, and 7.2

## Problem/Feature Description

The `ShippingRates` engine currently targets Rails 7.1. The maintainers want to publish it as a gem compatible with Rails 7.0, 7.1, and 7.2 before tagging v0.1.0. Following the `rails-engine-compatibility` skill, you must:

1. Update the gemspec to declare compatibility correctly
2. Create a multi-version CI configuration (GitHub Actions)
3. Identify any known breaking changes between these versions that affect the engine

The engine files are provided below. Extract them before beginning.

=============== FILE: shipping_rates.gemspec ===============
Gem::Specification.new do |spec|
  spec.name          = 'shipping_rates'
  spec.version       = '0.1.0'
  spec.summary       = 'Shipping rate calculator Rails engine'
  spec.files         = Dir['{app,lib}/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '~> 7.1'
end
=============== END FILE ===============

=============== FILE: lib/shipping_rates/engine.rb ===============
# frozen_string_literal: true

module ShippingRates
  class Engine < ::Rails::Engine
    isolate_namespace ShippingRates
  end
end
=============== END FILE ===============

## Output Specification

Produce:

- `shipping_rates.gemspec` — Updated with a Rails version constraint that allows 7.0, 7.1, and 7.2 (and not 8.x)
- `.github/workflows/ci.yml` — A GitHub Actions matrix CI that runs tests against Ruby 3.1 + Rails 7.0, Ruby 3.2 + Rails 7.1, and Ruby 3.3 + Rails 7.2
- `docs/compatibility_notes.md` — Notes on any breaking changes between Rails 7.0→7.1→7.2 relevant to engine authors (e.g. autoloading, deprecations, migration version format)
