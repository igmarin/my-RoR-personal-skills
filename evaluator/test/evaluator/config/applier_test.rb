# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class Config
    class ApplierTest < Minitest::Test
      def setup
        @store = mock
        @store.stubs(:current_llm_provider).returns(nil)
      end

      def test_call_returns_success
        @store.stubs(:assign_current_llm_provider)
        @store.stubs(:assign_max_execution_time)
        @store.stubs(:assign_allowed_commands)
        @store.stubs(:apply_provider_config)

        result = Applier.call(store: @store, data: { current_llm_provider: :openai })

        assert result[:success]
        assert result[:response][:applied]
      end

      def test_call_applies_current_provider
        @store.expects(:assign_current_llm_provider).with(:gemini)
        @store.stubs(:assign_max_execution_time)
        @store.stubs(:assign_allowed_commands)
        @store.stubs(:apply_provider_config)

        Applier.call(store: @store, data: { current_llm_provider: :gemini })
      end

      def test_call_applies_max_execution_time
        @store.expects(:assign_max_execution_time).with(60)
        @store.stubs(:assign_current_llm_provider)
        @store.stubs(:assign_allowed_commands)
        @store.stubs(:apply_provider_config)

        Applier.call(store: @store, data: { max_execution_time: 60 })
      end

      def test_call_applies_allowed_commands
        commands = %w[ls cat]
        @store.expects(:assign_allowed_commands).with(commands)
        @store.stubs(:assign_current_llm_provider)
        @store.stubs(:assign_max_execution_time)
        @store.stubs(:apply_provider_config)

        Applier.call(store: @store, data: { allowed_commands: commands })
      end

      def test_call_applies_provider_config
        providers = { openai: { api_key: 'key' } }
        @store.expects(:apply_provider_config).with(providers)
        @store.stubs(:assign_current_llm_provider)
        @store.stubs(:assign_max_execution_time)
        @store.stubs(:assign_allowed_commands)

        Applier.call(store: @store, data: { providers: providers })
      end

      def test_call_handles_llm_providers_config
        config = { openai: { api_key: 'new_key' } }
        @store.expects(:replace_provider_config).with(config)
        @store.stubs(:assign_current_llm_provider)
        @store.stubs(:assign_max_execution_time)
        @store.stubs(:assign_allowed_commands)

        Applier.call(store: @store, data: { llm_providers_config: config })
      end

      def test_call_returns_error_on_exception
        # Make assign_current_llm_provider raise when called
        @store.stubs(:assign_current_llm_provider).raises(StandardError.new('fail'))
        @store.stubs(:assign_max_execution_time)
        @store.stubs(:assign_allowed_commands)
        @store.stubs(:apply_provider_config)

        result = Applier.call(store: @store, data: { current_llm_provider: :openai })

        refute result[:success]
        assert_match(/fail/, result[:response][:error][:message])
      end
    end
  end
end
