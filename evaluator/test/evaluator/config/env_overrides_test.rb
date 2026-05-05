# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class Config
    class EnvOverridesTest < Minitest::Test
      def test_returns_nested_provider_overrides_for_present_env_values
        overrides = EnvOverrides.call(
          env: {
            'OPENAI_API_KEY' => 'openai-key',
            'GEMINI_API_KEY' => 'gemini-key',
            'GEMINI_LOCATION' => 'us-east1',
            'GEMINI_PROJECT_ID' => 'gemini-project'
          }
        )

        assert_equal(
          {
            openai: { api_key: 'openai-key' },
            gemini: {
              api_key: 'gemini-key',
              location: 'us-east1',
              project_id: 'gemini-project'
            }
          },
          overrides
        )
      end

      def test_omits_absent_env_values
        assert_equal({}, EnvOverrides.call(env: {}))
      end
    end
  end
end
