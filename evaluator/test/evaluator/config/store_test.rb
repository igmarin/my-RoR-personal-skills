# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class Config
    class StoreTest < Minitest::Test
      def test_applies_defaults_as_independent_provider_config
        store = Store.new
        defaults = Defaults.call

        Applier.call(store:, data: defaults)
        defaults[:llm_providers_config][:openai][:model] = 'mutated'

        assert_equal 'gpt-4o', store.model
      end

      def test_sets_custom_provider_values
        store = Store.new
        Applier.call(store:, data: Defaults.call)

        store.set_provider_setting(:custom, :model, 'custom-model')

        assert_equal 'custom-model', store.llm_providers_config[:custom][:model]
      end
    end
  end
end
