# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Clients
    class OpenAITest < Minitest::Test
      def setup
        Config.reset
        Config.current_llm_provider = :openai # Ensure OpenAI is the current provider for these tests
      end

      def test_call_returns_message_content_on_success
        # Arrange
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .to_return(
            status: 200,
            body: { choices: [{ message: { content: 'Hello', role: 'assistant' } }] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        # Act
        result = Providers::OpenAI.call(
          api_key: 'test_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi' }]
        )

        # Assert
        assert result[:success]
        assert_equal 'Hello', result[:response][:message]['content']
      end

      def test_call_returns_error_on_missing_api_key
        # Arrange
        # Config.api_key is nil by default unless set by ENV or setup block
        Config.setup do |config|
          config.set_provider_api_key(:openai, nil)
        end

        # Act
        result = Providers::OpenAI.call(
          api_key: nil, # Explicitly pass nil to ensure it's not picked up from ENV
          system_prompt: 'System',
          messages: []
        )

        # Assert
        refute result[:success]
        assert_equal 'OPENAI_API_KEY is not set in config for OpenAI', result[:response][:error][:message]
      end

      def test_call_returns_error_on_api_failure
        # Arrange
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .to_return(
            status: 400,
            body: 'Bad Request'
          )

        # Act
        result = Providers::OpenAI.call(
          api_key: 'test_key',
          system_prompt: 'System',
          messages: [{ role: 'user', content: 'Hi' }]
        )

        # Assert
        refute result[:success]
        assert_match(/API Request failed: 400 - Bad Request/, result[:response][:error][:message])
      end
    end
  end
end
