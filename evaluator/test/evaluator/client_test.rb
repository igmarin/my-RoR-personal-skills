# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class ClientTest < Minitest::Test
    def test_call_returns_message_content_on_success
      # Arrange
      stub_request(:post, 'https://api.openai.com/v1/chat/completions')
        .to_return(
          status: 200,
          body: { choices: [{ message: { content: 'Hello', role: 'assistant' } }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      # Act
      result = Client.call(
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
      original_api_key = Evaluator::Config.openai_api_key
      Evaluator::Config.openai_api_key = nil

      begin
        # Act
        result = Client.call(
          api_key: nil,
          system_prompt: 'System',
          messages: []
        )

        # Assert
        refute result[:success]
        assert_equal 'OPENAI_API_KEY is not set', result[:response][:error][:message]
      ensure
        Evaluator::Config.openai_api_key = original_api_key
      end
    end

    def test_call_returns_error_on_api_failure
      # Arrange
      stub_request(:post, 'https://api.openai.com/v1/chat/completions')
        .to_return(
          status: 400,
          body: 'Bad Request'
        )

      # Act
      result = Client.call(
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
