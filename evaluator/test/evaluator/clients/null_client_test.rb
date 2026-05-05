# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Clients
    module Providers
      class NullClientTest < Minitest::Test
        def setup
          Config.reset
        end

        def test_call_returns_failure_response
          result = NullClient.call(system_prompt: 'test', messages: [])

          refute result[:success]
          assert_kind_of Hash, result[:response]
          assert_kind_of Hash, result[:response][:error]
        end

        def test_call_includes_provider_name_in_error
          Config.setup do |c|
            c.current_llm_provider = :unsupported_provider
          end
          result = NullClient.call(system_prompt: 'test', messages: [])

          assert_match(/unsupported_provider/, result[:response][:error][:message])
        end

        def test_call_never_raises_exceptions
          # If this raises, the test will fail automatically
          NullClient.call(system_prompt: nil, messages: nil, tools: nil, bogus: 'value')
        end

        def test_call_returns_consistent_response_structure
          result = NullClient.call(system_prompt: 'test', messages: [])

          assert result.key?(:success)
          assert result.key?(:response)
          assert result[:response].key?(:error)
          assert result[:response][:error].key?(:message)
        end
      end
    end
  end
end
