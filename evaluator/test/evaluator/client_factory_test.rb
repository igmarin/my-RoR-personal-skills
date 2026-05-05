# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/client' # This is the factory client
require_relative '../../lib/clients/providers/openai'
require_relative '../../lib/clients/providers/gemini'
require_relative '../../lib/clients/providers/ollama'
require_relative '../../lib/clients/providers/null_client'

module Evaluator
  class ClientFactoryTest < Minitest::Test
    include Mocha::API # Include Mocha API for class method stubbing

    def setup
      Config.reset
    end

    def teardown
      Mocha::Mockery.instance.teardown # Clean up stubs after each test
    end

    def test_call_dispatches_to_openai_client_when_configured
      Config.current_llm_provider = :openai
      Config.setup do |config|
        config.set_provider_api_key(:openai, 'test_openai_key')
      end

      # Stub the OpenAI provider client class method
      Evaluator::Clients::Providers::OpenAI.stubs(:call).returns({ success: true, response: { message: { content: 'OpenAI response' } } })

      result = Client.call(system_prompt: 'System', messages: [{ role: 'user', content: 'Hi' }])

      assert result[:success]
      assert_equal 'OpenAI response', result[:response][:message][:content]
    end

    def test_call_dispatches_to_gemini_client_when_configured
      Config.current_llm_provider = :gemini
      Config.setup do |config|
        config.set_provider_api_key(:gemini, 'test_gemini_key')
        config.set_provider_project_id(:gemini, 'test-project')
        config.set_provider_location(:gemini, 'us-central1')
      end

      # Stub the Gemini provider client class method
      Evaluator::Clients::Providers::Gemini.stubs(:call).returns({ success: true, response: { message: { content: 'Gemini response' } } })

      result = Client.call(system_prompt: 'System', messages: [{ role: 'user', content: 'Hi' }])

      assert result[:success]
      assert_equal 'Gemini response', result[:response][:message][:content]
    end

    def test_call_dispatches_to_ollama_client_when_configured
      Config.current_llm_provider = :ollama
      Config.setup do |config|
        config.set_provider_model(:ollama, 'qwen2.5')
      end

      # Stub the Ollama provider client class method
      Evaluator::Clients::Providers::Ollama.stubs(:call).returns({ success: true, response: { message: { content: 'Ollama response' } } })

      result = Client.call(system_prompt: 'System', messages: [{ role: 'user', content: 'Hi' }])

      assert result[:success]
      assert_equal 'Ollama response', result[:response][:message][:content]
    end

    def test_call_dispatches_to_null_client_for_unsupported_provider
      Config.current_llm_provider = :unsupported_llm

      result = Client.call(system_prompt: 'System', messages: [{ role: 'user', content: 'Hi' }])

      refute result[:success]
      assert_match(/Unsupported or unconfigured LLM provider: 'unsupported_llm'/, result[:response][:error][:message])
    end

    def test_call_propagates_errors_from_provider_client
      Config.current_llm_provider = :openai
      Config.setup do |config|
        config.set_provider_api_key(:openai, 'test_openai_key')
      end

      # Stub the OpenAI provider client class method to return an error
      Evaluator::Clients::Providers::OpenAI.stubs(:call).returns({ success: false, response: { error: { message: 'Provider specific error' } } })

      result = Client.call(system_prompt: 'System', messages: [{ role: 'user', content: 'Hi' }])

      refute result[:success]
      assert_equal 'Provider specific error', result[:response][:error][:message]
    end
  end
end
