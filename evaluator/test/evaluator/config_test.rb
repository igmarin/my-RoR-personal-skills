# frozen_string_literal: true

require 'test_helper'

module Evaluator
  # Tests for Evaluator::Config
  class ConfigTest < Minitest::Test
    def setup
      Config.reset
    end

    def test_default_model_is_gpt4o
      assert_equal 'gpt-4o', Config.model
    end

    def test_default_max_execution_time
      assert_equal 30, Config.max_execution_time
    end

    def test_default_allowed_commands_is_nil
      assert_nil Config.allowed_commands
    end

    def test_default_openai_api_key_reads_from_env
      env_key = 'test_key_from_env'
      with_env('OPENAI_API_KEY' => env_key) do
        Config.reset

        assert_equal env_key, Config.openai_api_key
      end
    end

    def test_setup_yields_self_for_block_configuration
      Config.setup do |config|
        config.model = 'gpt-3.5-turbo'
        config.max_execution_time = 10
        config.allowed_commands = %w[rspec ruby]
      end

      assert_equal 'gpt-3.5-turbo', Config.model
      assert_equal 10, Config.max_execution_time
      assert_equal %w[rspec ruby], Config.allowed_commands
    end

    def test_reset_restores_defaults
      Config.model = 'some-other-model'
      Config.reset

      assert_equal 'gpt-4o', Config.model
    end

    private

    # Temporarily overrides environment variables for the duration of the block.
    #
    # @param vars [Hash] The environment variable overrides.
    # @return [void]
    def with_env(vars)
      old = vars.keys.to_h { |key| [key, ENV.fetch(key, nil)] }
      vars.each { |key, value| ENV[key] = value }
      yield
    ensure
      old.each { |key, value| ENV[key] = value }
    end
  end
end
