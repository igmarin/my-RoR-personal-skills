# frozen_string_literal: true

module Evaluator
  class Config
    # Reader methods exposed by the Config facade.
    module FacadeReaders
      # Returns the current LLM provider.
      #
      # @return [Symbol, nil] current provider
      def current_llm_provider
        store.current_llm_provider
      end

      # Returns maximum command execution time.
      #
      # @return [Integer, nil] maximum execution time in seconds
      def max_execution_time
        store.max_execution_time
      end

      # Returns allowed command list.
      #
      # @return [Array<String>, nil] allowed commands
      def allowed_commands
        store.allowed_commands
      end

      # Returns provider configuration.
      #
      # @return [Hash] provider configuration by provider name
      def llm_providers_config
        store.llm_providers_config
      end

      # Returns the API key for the current LLM provider.
      #
      # @return [String, nil] API key for the current provider
      def api_key
        store.api_key
      end

      # Returns the model for the current LLM provider.
      #
      # @return [String, nil] model name for the current provider
      def model
        store.model
      end
    end
  end
end
