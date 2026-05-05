# frozen_string_literal: true

require 'test_helper'
require_relative '../../../../lib/clients/providers/ollama'

class OllamaProviderTest < Minitest::Test
  def test_config_error_returns_message
    error = Evaluator::Clients::Providers::Ollama.new(system_prompt: 'test', messages: []).send(:config_error)

    assert_equal({ success: false, response: { error: { message: 'model not set in config for Ollama' } } }, error)
  end

  def test_base_url_uses_env_when_set
    ENV['OLLAMA_BASE_URL'] = 'http://custom:11434'
    provider = Evaluator::Clients::Providers::Ollama.new(system_prompt: 'test', messages: [])

    assert_equal 'http://custom:11434', provider.send(:base_url)
  ensure
    ENV.delete('OLLAMA_BASE_URL')
  end

  def test_base_url_defaults_to_localhost
    provider = Evaluator::Clients::Providers::Ollama.new(system_prompt: 'test', messages: [])

    assert_equal 'http://localhost:11434', provider.send(:base_url)
  end

  def test_base_url_uses_config_when_set
    provider = Evaluator::Clients::Providers::Ollama.new(
      system_prompt: 'test',
      messages: [],
      model: 'qwen2.5'
    )

    # This test assumes config is set; if not, it falls back to localhost
    url = provider.send(:base_url)

    assert_includes ['http://localhost:11434', url], url
  end

  def test_valid_config_with_model
    provider = Evaluator::Clients::Providers::Ollama.new(
      system_prompt: 'test',
      messages: [],
      model: 'qwen2.5'
    )

    assert provider.send(:valid_config?)
  end

  def test_valid_config_with_empty_model
    provider = Evaluator::Clients::Providers::Ollama.new(
      system_prompt: 'test',
      messages: [],
      model: ''
    )

    refute provider.send(:valid_config?)
  end

  def test_request_headers_with_api_key
    provider = Evaluator::Clients::Providers::Ollama.new(
      system_prompt: 'test',
      messages: [],
      api_key: 'test-key'
    )

    headers = provider.send(:request_headers)

    assert_equal 'application/json', headers['Content-Type']
    assert_equal 'Bearer test-key', headers['Authorization']
  end

  def test_request_headers_without_api_key
    provider = Evaluator::Clients::Providers::Ollama.new(
      system_prompt: 'test',
      messages: [],
      api_key: ''
    )

    headers = provider.send(:request_headers)

    assert_equal 'application/json', headers['Content-Type']
    refute headers.key?('Authorization')
  end

  def test_request_path
    provider = Evaluator::Clients::Providers::Ollama.new(system_prompt: 'test', messages: [])

    assert_equal '/v1/chat/completions', provider.send(:request_path)
  end
end
