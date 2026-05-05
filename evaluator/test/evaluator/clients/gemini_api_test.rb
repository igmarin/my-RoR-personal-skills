# frozen_string_literal: true

# frozen_string_literal: true'

require 'test_helper'

module Evaluator
  module Clients
    class GeminiAPITest < Minitest::Test
      def setup
        Config.reset
        Config.current_llm_provider = :gemini
      end

      def test_call_returns_message_content_on_success
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        stub_request(:post, 'https://us-central1-aiplatform.googleapis.com/v1/projects/test-project/locations/us-central1/endpoints/openapi/chat/completions')
          .to_return(
            status: 200,
            body: { choices: [{ message: { content: 'Hello Gemini', role: 'assistant' } }] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi Gemini' }]
        )

        assert result[:success]
        assert_equal 'Hello Gemini', result[:response][:message]['content']
      end

      def test_call_returns_error_on_api_failure
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        stub_request(:post, 'https://us-central1-aiplatform.googleapis.com/v1/projects/test-project/locations/us-central1/endpoints/openapi/chat/completions')
          .to_return(status: 400, body: 'Gemini Bad Request')

        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi Gemini' }]
        )

        refute result[:success]
        assert_match(/API Request failed: 400 - Gemini Bad Request/, result[:response][:error][:message])
      end

      def test_call_handles_timeout
        Config.setup do |config|
          config.set_provider_api_key(:gemini, 'test_gemini_key')
          config.set_provider_project_id(:gemini, 'test-project')
          config.set_provider_location(:gemini, 'us-central1')
        end

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/v1/projects/test-project/locations/us-central1/endpoints/openapi/chat/completions})
          .to_raise(Faraday::TimeoutError)

        result = Providers::Gemini.call(
          api_key: 'test_gemini_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi' }]
        )

        refute result[:success]
      end
    end
  end
end
