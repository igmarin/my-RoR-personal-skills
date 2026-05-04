# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'fileutils'

module Evaluator
  # Tests for Evaluator::Config with hierarchical loading.
  class ConfigTest < Minitest::Test
    include Mocha::API

    def setup
      Config.reset
      Config.current_llm_provider = :openai
    end

    def teardown
      Mocha::Mockery.instance.teardown
    end

    def test_default_model_is_gpt4o
      assert_equal 'gpt-4o', Config.model
    end

    def test_default_max_execution_time
      assert_equal 30, Config.max_execution_time
    end

    def test_default_openai_api_key_reads_from_env
      env_key = 'test_key_from_env'
      with_env('OPENAI_API_KEY' => env_key) do
        Config.reset

        assert_equal env_key, Config.api_key
      end
    end

    def test_hierarchy_local_json_overrides_home_json
      Dir.mktmpdir do |home_dir|
        Dir.mktmpdir do |local_dir|
          home_config = File.join(home_dir, Config::CONFIG_FILENAME)
          local_config = File.join(local_dir, Config::CONFIG_FILENAME)

          File.write(home_config, { max_execution_time: 50, providers: { openai: { model: 'home-model' } } }.to_json)
          File.write(local_config, { max_execution_time: 100 }.to_json)

          Dir.stubs(:home).returns(home_dir)
          Dir.chdir(local_dir) do
            Config.reset

            assert_equal 100, Config.max_execution_time
            assert_equal 'home-model', Config.model # Merged from home
          end
        end
      end
    end

    def test_hierarchy_env_overrides_local_json
      Dir.mktmpdir do |local_dir|
        local_config = File.join(local_dir, Config::CONFIG_FILENAME)
        File.write(local_config, { providers: { openai: { api_key: 'json-key' } } }.to_json)

        Dir.chdir(local_dir) do
          with_env('OPENAI_API_KEY' => 'env-key') do
            Config.reset

            assert_equal 'env-key', Config.api_key
          end
        end
      end
    end

    def test_setup_block_overrides_everything
      Config.setup do |config|
        config.current_llm_provider = :openai
        config.set_provider_model(:openai, 'block-model')
      end

      assert_equal 'block-model', Config.model
    end

    def test_graceful_handling_of_invalid_json
      Dir.mktmpdir do |local_dir|
        local_config = File.join(local_dir, Config::CONFIG_FILENAME)
        File.write(local_config, 'invalid { json')

        Dir.chdir(local_dir) do
          _, stderr = capture_io do
            Config.reset
          end

          assert_match(/Warning: Failed to parse config file/, stderr)
          assert_equal 'gpt-4o', Config.model # Falls back to code defaults
        end
      end
    end

    private

    def with_env(vars)
      old = vars.keys.to_h { |key| [key, ENV.fetch(key, nil)] }
      vars.each { |key, value| ENV[key] = value }
      yield
    ensure
      old.each { |key, value| ENV[key] = value }
    end
  end
end
