# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'

module Evaluator
  class Config
    class JsonLoaderTest < Minitest::Test
      def test_loads_scalar_values_and_provider_hashes
        with_config_file(
          current_llm_provider: 'gemini',
          max_execution_time: 45,
          allowed_commands: ['ruby'],
          providers: { gemini: { location: 'us-east1' } }
        ) do |path|
          config = JsonLoader.call(path)

          assert_equal 'gemini', config[:current_llm_provider]
          assert_equal 45, config[:max_execution_time]
          assert_equal ['ruby'], config[:allowed_commands]
          assert_equal({ gemini: { location: 'us-east1' } }, config[:providers])
        end
      end

      def test_missing_providers_returns_empty_provider_hash_without_warning
        with_config_file(max_execution_time: 45) do |path|
          _, stderr = capture_io do
            @config = JsonLoader.call(path)
          end

          assert_empty stderr
          assert_equal({}, @config[:providers])
        end
      end

      def test_non_hash_provider_entry_is_skipped
        with_config_file(providers: { openai: 'not-a-hash', gemini: { model: 'gemini-pro' } }) do |path|
          _, stderr = capture_io do
            @config = JsonLoader.call(path)
          end

          assert_match(/provider 'openai'.*not a valid hash/, stderr)
          assert_equal({ gemini: { model: 'gemini-pro' } }, @config[:providers])
        end
      end

      def test_invalid_json_returns_empty_hash
        with_raw_config('invalid { json') do |path|
          _, stderr = capture_io do
            @config = JsonLoader.call(path)
          end

          assert_match(/Failed to parse config file/, stderr)
          assert_equal({}, @config)
        end
      end

      private

      def with_config_file(payload, &)
        with_raw_config(payload.to_json, &)
      end

      def with_raw_config(content)
        Dir.mktmpdir do |dir|
          path = Pathname.new(dir).join(Config::CONFIG_FILENAME)
          File.write(path, content)

          yield path
        end
      end
    end
  end
end
