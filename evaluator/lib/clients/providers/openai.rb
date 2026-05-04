# frozen_string_literal: true

require_relative '../base_client'

module Evaluator
  module Clients
    module Providers
      # OpenAI-specific LLM client.
      # Inherits common logic from BaseClient.
      class OpenAI < BaseClient
        attr_reader :api_key, :model

        # Initializes the OpenAI client.
        # @param system_prompt [String]
        # @param messages [Array<Hash>]
        # @param tools [Array<Hash>]
        # @param options [Hash]
        def initialize(system_prompt:, messages:, tools: [], **options)
          super
          @api_key = @config.api_key
          @model = @config.model
        end

        protected

        # @return [String]
        def base_url
          'https://api.openai.com'
        end

        # @return [String]
        def request_path
          '/v1/chat/completions'
        end

        # @return [Hash]
        def config_error
          { success: false, response: { error: { message: 'OPENAI_API_KEY is not set in config for OpenAI' } } }
        end
      end
    end
  end
end
