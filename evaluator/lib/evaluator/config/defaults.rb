# frozen_string_literal: true

module Evaluator
  class Config
    # Builds the default evaluator configuration state.
    class Defaults
      # Returns the default configuration values.
      #
      # @return [Hash] result envelope with default provider, timeout, command, and provider settings
      def self.call
        { success: true, response: { config: config } }
      end

      # Builds the raw default configuration hash.
      #
      # @return [Hash] default provider, timeout, command, and provider settings
      def self.config
        {
          current_llm_provider: :openai,
          max_execution_time: 30,
          allowed_commands: nil,
          llm_providers_config: {
            openai: { api_key: nil, model: 'gpt-4o' },
            gemini: {
              api_key: nil,
              model: 'gemini-1.5-flash-latest',
              location: 'us-central1',
              project_id: nil
            },
            ollama: { api_key: nil, model: 'qwen:7b', base_url: nil }
          }
        }
      end
    end
  end
end