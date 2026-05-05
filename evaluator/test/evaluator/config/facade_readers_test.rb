# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class Config
    class FacadeReadersTest < Minitest::Test
      def setup
        @store = mock
        Config.stubs(:store).returns(@store)
      end

      def teardown
        Config.unstub(:store) if Config.respond_to?(:unstub)
      end

      def test_current_llm_provider_delegates_to_store
        @store.expects(:current_llm_provider).returns(:openai)

        assert_equal :openai, Config.current_llm_provider
      end

      def test_max_execution_time_delegates_to_store
        @store.expects(:max_execution_time).returns(30)

        assert_equal 30, Config.max_execution_time
      end

      def test_allowed_commands_delegates_to_store
        commands = %w[ls cat]
        @store.expects(:allowed_commands).returns(commands)

        assert_equal commands, Config.allowed_commands
      end

      def test_llm_providers_config_delegates_to_store
        config = { openai: { api_key: 'key' } }
        @store.expects(:llm_providers_config).returns(config)

        assert_equal config, Config.llm_providers_config
      end

      def test_api_key_delegates_to_store
        @store.expects(:api_key).returns('test-key')

        assert_equal 'test-key', Config.api_key
      end

      def test_model_delegates_to_store
        @store.expects(:model).returns('gpt-4o')

        assert_equal 'gpt-4o', Config.model
      end
    end
  end
end
