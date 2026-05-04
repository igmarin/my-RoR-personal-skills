# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Clients
    class GeminiTest < Minitest::Test
      def setup
        Config.reset
        Config.current_llm_provider = :gemini # Ensure Gemini is the current provider for these tests
      end

      def test_call_returns_message_content_on_success
        # Arrange
        Config.setup do |config|
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        stub_request(:post, 'https://us-central1-aiplatform.googleapis.com/v1/projects/test-project/locations/us-central1/endpoints/openapi/chat/completions')
          .to_return(
            status: 200,
            body: { choices: [{ message: { content: 'Hello Gemini', role: 'assistant' } }] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        # Act
        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi Gemini' }]
        )

        # Assert
        assert result[:success]
        assert_equal 'Hello Gemini', result[:response][:message]['content']
      end

      def test_call_returns_error_on_missing_api_key
        # Arrange
        Config.setup do |config|
          config.set_provider_api_key(:gemini, nil)
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        # Act
        result = Providers::Gemini.call(
          api_key: nil, # Explicitly pass nil
          system_prompt: 'System',
          messages: []
        )

        # Assert
        refute result[:success]
        assert_equal 'GEMINI_API_KEY not set for Gemini', result[:response][:error][:message]
      end

      def test_call_returns_error_on_missing_project_id
        # Arrange
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, nil)
          config.set_provider_location(:gemini, 'us-central1')
        end

        # Act
        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: []
        )

        # Assert
        refute result[:success]
        assert_equal 'GEMINI_PROJECT_ID not set for Gemini', result[:response][:error][:message]
      end

      def test_call_returns_error_on_missing_location
        # Arrange
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, nil)
        end

        # Act
        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: []
        )

        # Assert
        refute result[:success]
        assert_equal 'GEMINI_LOCATION not set for Gemini', result[:response][:error][:message]
      end

      def test_call_returns_error_on_api_failure
        # Arrange
        Config.setup do |config|
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        stub_request(:post, 'https://us-central1-aiplatform.googleapis.com/v1/projects/test-project/locations/us-central1/endpoints/openapi/chat/completions')
          .to_return(
            status: 400,
            body: 'Gemini Bad Request'
          )

        # Act
        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi Gemini' }]
        )

        # Assert
        refute result[:success]
        assert_match(/API Request failed: 400 - Gemini Bad Request/, result[:response][:error][:message])
      end
    end
  end
end
