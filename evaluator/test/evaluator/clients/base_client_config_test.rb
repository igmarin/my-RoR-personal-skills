# frozen_string_literal: true

# frozen_string_literal: true

require 'test_helper'
require 'faraday'
require 'json'

module Evaluator
  module Clients
    class BaseClientConfigTest < Minitest::Test
      def setup
        Config.reset
        @client_class = Class.new(BaseClient) do
          def base_url
            'https://api.example.com'
          end

          def request_path
            '/v1/chat'
          end

          def valid_config?
            !@api_key.to_s.empty?
          end

          def config_error
            { success: false, response: { error: { message: 'Config error' } } }
          end
        end
      end

      def test_self_call_delegates_to_instance
        result = { success: true, response: { message: 'test' } }
        @client_class.expects(:new).returns(mock(call: result))
        @client_class.call(system_prompt: 'test', messages: [])

        assert result[:success]
      end

      def test_call_returns_config_error_when_invalid
        client = @client_class.new(system_prompt: 'test', messages: [], api_key: '')
        result = client.call

        refute result[:success]
        assert_equal 'Config error', result[:response][:error][:message]
      end

      def test_call_returns_success_on_valid_config
        stub_request(:post, 'https://api.example.com/v1/chat')
          .to_return(status: 200, body: { choices: [{ message: { content: 'hello' } }] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        client = @client_class.new(system_prompt: 'test', messages: [{ role: 'user', content: 'hi' }], api_key: 'key')
        result = client.call

        assert result[:success]
        assert_equal 'hello', result[:response][:message]['content']
      end

      def test_call_handles_api_failure
        stub_request(:post, 'https://api.example.com/v1/chat')
          .to_return(status: 400, body: 'Bad Request')

        client = @client_class.new(system_prompt: 'test', messages: [], api_key: 'key')
        result = client.call

        refute result[:success]
        assert_match(/API Request failed/, result[:response][:error][:message])
      end

      def test_call_handles_missing_message_in_response
        stub_request(:post, 'https://api.example.com/v1/chat')
          .to_return(status: 200, body: { choices: [] }.to_json,
                     headers: { 'Content-Type' => 'application/json' })

        client = @client_class.new(system_prompt: 'test', messages: [], api_key: 'key')
        result = client.call

        refute result[:success]
        assert_match(/missing message content/i, result[:response][:error][:message])
      end
    end
  end
end
