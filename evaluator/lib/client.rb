# frozen_string_literal: true

require_relative 'config'
require_relative 'clients/providers/openai'
require_relative 'clients/providers/gemini'
require_relative 'clients/providers/ollama'
require_relative 'clients/providers/null_client'

module Evaluator
  # Client is a factory that dispatches requests to the appropriate LLM provider client.
  # Following ruby-service-objects and yard-documentation standards.
  class Client
    class << self
      # Dispatches the call to the configured LLM provider using keyword arguments.
      #
      # @param system_prompt [String] The system instruction for the LLM.
      # @param messages [Array<Hash>] The list of conversation messages.
      # @param tools [Array<Hash>] (optional) Array of tool definitions.
      # @param options [Hash] (optional) Additional provider-specific options.
      # @return [Hash] with :success [Boolean] and :response [Hash] keys.
      def call(system_prompt:, messages:, tools: [], **options)
        provider_client_class.call(
          system_prompt: system_prompt,
          messages: messages,
          tools: tools,
          **options
        )
      rescue StandardError => e
        log_dispatch_error(e)
        { success: false, response: { error: { message: "LLM Dispatch Error: #{e.message}" } } }
      end

      private

      # Maps the current provider to its implementation class.
      # Returns NullClient if no match is found (Null Object Pattern).
      #
      # @return [Class]
      def provider_client_class
        case Evaluator::Config.current_llm_provider
        when :openai
          Evaluator::Clients::Providers::OpenAI
        when :gemini
          Evaluator::Clients::Providers::Gemini
        when :ollama
          Evaluator::Clients::Providers::Ollama
        else
          Evaluator::Clients::Providers::NullClient
        end
      end

      # Logs dispatch-level errors.
      #
      # @param error [StandardError]
      def log_dispatch_error(error)
        message = "LLM Client Dispatch Error: #{error.message}"
        backtrace = error.backtrace.first(5).join("\n")

        logger = defined?(Rails) ? Rails.logger : nil
        if logger
          logger.error(message)
          logger.error(backtrace)
        else
          warn(message)
          warn(backtrace)
        end
      end
    end
  end
end
