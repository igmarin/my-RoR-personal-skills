# frozen_string_literal: true

require_relative '../base_client'

module Evaluator
  module Clients
    module Providers
      # Ollama-specific LLM client.
      # Extends BaseClient to interact with an Ollama server (commonly used for open‑source models such as Qwen 3.5).
      class Ollama < BaseClient
        protected

        # Base URL for the Ollama service.
        # Checks the OLLAMA_BASE_URL env var, then the evaluator config, then falls back to localhost.
        # @return [String]
        def base_url
          env_url = ENV['OLLAMA_BASE_URL']
          return env_url unless env_url.to_s.empty?

          config_url = Evaluator::Config.llm_providers_config.dig(:ollama, :base_url)
          return config_url unless config_url.to_s.empty?

          'http://localhost:11434'
        end

        # Path for chat completions. Ollama follows the OpenAI compatible endpoint.
        # @return [String]
        def request_path
          '/v1/chat/completions'
        end

        # Error returned when the model is not configured.
        # @return [Hash]
        def config_error
          { success: false, response: { error: { message: 'model not set in config for Ollama' } } }
        end

        # Ollama does not require an API key; validation only checks for a model.
        # @return [Boolean]
        def valid_config?
          !!@model && !@model.to_s.empty?
        end

        # Request headers omit Authorization if no API key is set.
        # @return [Hash]
        def request_headers
          headers = { 'Content-Type' => 'application/json' }
          headers['Authorization'] = "Bearer #{@api_key}" if @api_key && !@api_key.to_s.empty?
          headers
        end
      end
    end
  end
end
