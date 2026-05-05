# frozen_string_literal: true

require_relative '../base_client'

module Evaluator
  module Clients
    module Providers
      # Ollama-specific LLM client.
      # Extends BaseClient to interact with an Ollama server (commonly used for open‑source models such as Qwen 3.5).
      class Ollama < BaseClient
        protected

        # Base URL for the Ollama service. Can be overridden via the OLLAMA_BASE_URL env var.
        # @return [String]
        def base_url
          ENV['OLLAMA_BASE_URL'] || 'http://localhost:11434'
        end

        # Path for chat completions. Ollama follows the OpenAI compatible endpoint.
        # @return [String]
        def request_path
          '/v1/chat/completions'
        end

        # Error returned when the base URL or model is not configured.
        # @return [Hash]
        def config_error
          { success: false, response: { error: { message: "OLLAMA_BASE_URL or model not set in config for Ollama" } } }
        end
      end
    end
  end
end