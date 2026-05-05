# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class Config
    class FacadeWritersTest < Minitest::Test
      def setup
        @store = mock
        Config.stubs(:store).returns(@store)
      end

      def teardown
        Config.unstub(:store) if Config.respond_to?(:unstub)
      end

      def test_set_provider_api_key_calls_store
        @store.expects(:set_provider_setting).with(:openai, :api_key, 'new-key')
        Config.set_provider_api_key(:openai, 'new-key')
      end

      def test_set_provider_model_calls_store
        @store.expects(:set_provider_setting).with(:gemini, :model, 'gemini-pro')
        Config.set_provider_model(:gemini, 'gemini-pro')
      end

      def test_set_provider_location_calls_store
        @store.expects(:set_provider_setting).with(:gemini, :location, 'europe-west1')
        Config.set_provider_location(:gemini, 'europe-west1')
      end

      def test_set_provider_project_id_calls_store
        @store.expects(:set_provider_setting).with(:gemini, :project_id, 'proj-123')
        Config.set_provider_project_id(:gemini, 'proj-123')
      end

      def test_current_llm_provider_assignment_calls_store
        @store.expects(:assign_current_llm_provider).with(:anthropic)
        Config.current_llm_provider = :anthropic
      end

      def test_max_execution_time_assignment_calls_store
        @store.expects(:assign_max_execution_time).with(60)
        Config.max_execution_time = 60
      end

      def test_allowed_commands_assignment_calls_store
        commands = %w[ls cat]
        @store.expects(:assign_allowed_commands).with(commands)
        Config.allowed_commands = commands
      end

      def test_llm_providers_config_assignment_calls_store
        config = { openai: { api_key: 'key' } }
        @store.expects(:replace_provider_config).with(config)
        Config.llm_providers_config = config
      end

      def test_provider_settings_constant_has_required_mappings
        assert FacadeWriters::PROVIDER_SETTINGS.key?(:api_key)
        assert FacadeWriters::PROVIDER_SETTINGS.key?(:model)
        assert FacadeWriters::PROVIDER_SETTINGS.key?(:location)
        assert FacadeWriters::PROVIDER_SETTINGS.key?(:project_id)
      end
    end
  end
end
