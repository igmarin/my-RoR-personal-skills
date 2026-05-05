# frozen_string_literal: true

require_relative '../base_client'

module Evaluator
  module Clients
    module Providers
      # Gemini-specific LLM client using the OpenAI-compatible endpoint.
      # Inherits common logic from BaseClient.
      class Gemini < BaseClient
        attr_reader :location, :project_id

        # Initializes the Gemini client.
        # @param system_prompt [String]
        # @param messages [Array<Hash>]
        # @param tools [Array<Hash>]
        # @param options [Hash]
        # @raise [StandardError] if configuration is invalid (handled gracefully in call)
        def initialize(system_prompt:, messages:, tools: [], **options)
          super
          config = Evaluator::Config
          @location = options[:location] || config.llm_providers_config.dig(:gemini, :location)
          @project_id = options[:project_id] || config.llm_providers_config.dig(:gemini, :project_id)
        end

        protected

        # @return [String]
        def base_url
          "https://#{@location}-aiplatform.googleapis.com"
        end

        # @return [String]
        def request_path
          "/v1/projects/#{@project_id}/locations/#{@location}/endpoints/openapi/chat/completions"
        end

        # Model name is not used in OpenAI-compatible endpoint
        # Kept for potential future use with native Gemini API
        # @return [String]
        def model_name
          "google/#{@model}"
        end

        # @return [Boolean]
        def valid_config?
          !@api_key.to_s.strip.empty? && !@project_id.to_s.strip.empty? && !@location.to_s.strip.empty?
        end

        # @return [Hash]
        def config_error
          missing = missing_config_keys
          message = if missing.length > 1
                      "#{missing[0...-1].join(', ')}, and #{missing[-1]} not set for Gemini"
                    else
                      "#{missing.first} not set for Gemini"
                    end
          { success: false, response: { error: { message: message } } }
        end

        private

        # @return [Array<String>]
        def missing_config_keys
          missing = []
          missing << 'GEMINI_API_KEY' if @api_key.to_s.strip.empty?
          missing << 'GEMINI_PROJECT_ID' if @project_id.to_s.strip.empty?
          missing << 'GEMINI_LOCATION' if @location.to_s.strip.empty?
          missing
        end
      end
    end
  end
end
