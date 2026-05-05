# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class Config
    class DefaultsTest < Minitest::Test
      def test_call_returns_success
        result = Defaults.call

        assert result[:success]
        assert_kind_of Hash, result[:response][:config]
      end

      def test_config_returns_hash_with_required_keys
        config = Defaults.config

        assert_kind_of Symbol, config[:current_llm_provider]
        assert_kind_of Integer, config[:max_execution_time]
        assert_includes [Array, NilClass], config[:allowed_commands].class
        assert_kind_of Hash, config[:llm_providers_config]
      end

      def test_config_has_openai_provider
        config = Defaults.config

        assert config[:llm_providers_config].key?(:openai)
        assert_equal 'gpt-4o', config[:llm_providers_config][:openai][:model]
      end

      def test_config_has_gemini_provider
        config = Defaults.config

        assert config[:llm_providers_config].key?(:gemini)
        gemini = config[:llm_providers_config][:gemini]

        assert_equal 'gemini-1.5-flash-latest', gemini[:model]
        assert_equal 'us-central1', gemini[:location]
      end

      def test_default_provider_is_openai
        config = Defaults.config

        assert_equal :openai, config[:current_llm_provider]
      end

      def test_default_max_execution_time_is_30
        config = Defaults.config

        assert_equal 30, config[:max_execution_time]
      end

      def test_default_allowed_commands_is_nil
        config = Defaults.config

        assert_nil config[:allowed_commands]
      end
    end
  end
end
