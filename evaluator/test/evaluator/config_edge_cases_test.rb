# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'fileutils'

module Evaluator
  class ConfigEdgeCasesTest < Minitest::Test
    def setup
      @home_dir = Dir.mktmpdir
      @local_dir = Dir.mktmpdir
      Dir.stubs(:home).returns(@home_dir)

      Dir.chdir(@local_dir) do
        Config.reset
        Config.current_llm_provider = :openai
      end
    end

    def teardown
      Dir.unstub(:home)
      FileUtils.rm_rf(@home_dir)
      FileUtils.rm_rf(@local_dir)
    end

    def test_gemini_environment_overrides_file_values
      with_local_config(gemini_file_config) do
        with_env(
          'GEMINI_API_KEY' => 'env-gemini-key',
          'GEMINI_LOCATION' => 'us-east1',
          'GEMINI_PROJECT_ID' => 'env-project'
        ) do
          Config.reset

          assert_equal 'env-gemini-key', Config.api_key
          assert_equal 'json-gemini-model', Config.model
          assert_equal 'us-east1', Config.llm_providers_config[:gemini][:location]
          assert_equal 'env-project', Config.llm_providers_config[:gemini][:project_id]
        end
      end
    end

    def test_local_scalar_config_without_providers_does_not_warn
      with_local_config(max_execution_time: 120, allowed_commands: ['ruby']) do
        _, stderr = capture_io do
          Config.reset
        end

        assert_empty stderr
        assert_equal 120, Config.max_execution_time
        assert_equal ['ruby'], Config.allowed_commands
      end
    end

    def test_non_hash_provider_entry_is_skipped_with_warning
      with_local_config(providers: { openai: 'not-a-hash' }) do
        _, stderr = capture_io do
          Config.reset
        end

        assert_match(/provider 'openai'.*not a valid hash/, stderr)
        assert_equal 'gpt-4o', Config.model
      end
    end

    def test_top_level_non_hash_config_is_skipped_with_warning
      with_local_config(['not-a-hash']) do
        _, stderr = capture_io do
          Config.reset
        end

        assert_match(/not a valid JSON hash/, stderr)
        assert_equal 30, Config.max_execution_time
      end
    end

    def test_provider_setters_initialize_custom_provider_config
      Config.set_provider_model(:custom, 'custom-model')
      Config.set_provider_api_key(:custom, 'custom-key')

      assert_equal({ model: 'custom-model', api_key: 'custom-key' }, Config.llm_providers_config[:custom])
    end

    def test_string_provider_writer_normalizes_to_symbol
      Config.current_llm_provider = 'openai'

      assert_equal :openai, Config.current_llm_provider
      assert_equal 'gpt-4o', Config.model
    end

    def test_null_current_provider_config_is_ignored
      with_local_config(current_llm_provider: nil) do
        Config.reset

        assert_equal :openai, Config.current_llm_provider
      end
    end

    private

    def gemini_file_config
      {
        current_llm_provider: 'gemini',
        providers: {
          gemini: {
            api_key: 'json-gemini-key',
            model: 'json-gemini-model',
            location: 'europe-west1',
            project_id: 'json-project'
          }
        }
      }
    end

    def with_local_config(payload, &)
      Dir.mktmpdir do |local_dir|
        local_config = File.join(local_dir, Config::CONFIG_FILENAME)
        File.write(local_config, payload.to_json)

        Dir.chdir(local_dir, &)
      end
    end

    def with_env(vars)
      old = vars.keys.to_h { |key| [key, ENV.fetch(key, nil)] }
      vars.each { |key, value| ENV[key] = value }
      yield
    ensure
      old.each { |key, value| ENV[key] = value }
    end
  end
end
