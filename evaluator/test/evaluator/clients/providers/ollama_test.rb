# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/clients/providers/ollama'

class OllamaProviderTest < Minitest::Test
  def test_config_error_returns_message
    error = Evaluator::Clients::Providers::Ollama.new.send(:config_error)
    assert_equal({ success: false, response: { error: { message: "OLLAMA_BASE_URL or model not set in config for Ollama" } } }, error)
  end

  def test_base_url_uses_env_when_set
    ENV['OLLAMA_BASE_URL'] = 'http://custom:11434'
    provider = Evaluator::Clients::Providers::Ollama.new
    assert_equal 'http://custom:11434', provider.send(:base_url)
  ensure
    ENV.delete('OLLAMA_BASE_URL')
  end
end
