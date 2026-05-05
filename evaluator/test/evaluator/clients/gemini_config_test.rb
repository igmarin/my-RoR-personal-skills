# frozen_string_literal: true

# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Clients
    class GeminiConfigTest < Minitest::Test
      def setup
        Config.reset
        Config.current_llm_provider = :gemini
      end

      def test_call_returns_error_on_missing_api_key
        Config.setup do |config|
          config.set_provider_api_key(:gemini, nil)
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        result = Providers::Gemini.call(
          api_key: nil,
          system_prompt: 'System',
          messages: []
        )

        refute result[:success]
        assert_equal 'GEMINI_API_KEY not set for Gemini', result[:response][:error][:message]
      end

      def test_call_returns_error_on_missing_project_id
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, nil)
          config.set_provider_location(:gemini, 'us-central1')
        end

        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: []
        )

        refute result[:success]
        assert_equal 'GEMINI_PROJECT_ID not set for Gemini', result[:response][:error][:message]
      end

      def test_call_returns_error_on_missing_location
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, nil)
        end

        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: []
        )

        refute result[:success]
        assert_equal 'GEMINI_LOCATION not set for Gemini', result[:response][:error][:message]
      end

      def test_call_returns_error_on_api_key_and_project_id_missing
        Config.setup do |config|
          config.set_provider_api_key(:gemini, nil)
          config.set_provider_project_id(:gemini, nil)
          config.set_provider_location(:gemini, 'us-central1')
        end

        result = Providers::Gemini.call(
          api_key: nil,
          system_prompt: 'System',
          messages: []
        )

        refute result[:success]
        assert_match(/GEMINI_API_KEY, and GEMINI_PROJECT_ID not set/, result[:response][:error][:message])
      end

      def test_base_url_returns_correct_endpoint
        gemini = Providers::Gemini.new(
          system_prompt: 'test',
          messages: [],
          location: 'europe-west1'
        )

        assert_equal 'https://europe-west1-aiplatform.googleapis.com', gemini.send(:base_url)
      end

      def test_request_path_includes_project_and_location
        gemini = Providers::Gemini.new(
          system_prompt: 'test',
          messages: [],
          project_id: 'my-project',
          location: 'us-central1'
        )
        path = gemini.send(:request_path)

        assert_match %r{/v1/projects/my-project/locations/us-central1/endpoints/openapi/chat/completions}, path
      end

      def test_model_name_returns_google_prefixed_model
        gemini = Providers::Gemini.new(
          system_prompt: 'test',
          messages: [],
          model: 'gemini-1.5-pro'
        )

        assert_equal 'google/gemini-1.5-pro', gemini.send(:model_name)
      end
    end
  end
end
