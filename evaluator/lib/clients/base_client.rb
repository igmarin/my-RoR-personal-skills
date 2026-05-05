# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative '../config'

module Evaluator
  module Clients
    # Base class for all LLM provider clients.
    # Implements common Faraday logic, response handling, and error logging.
    # Following the Template Method pattern and ruby-service-objects standards.
    class BaseClient
      API_FAILED = 'API Request failed'

      attr_reader :messages, :system_prompt, :tools, :api_key, :model

      # Standard entry point for the service object.
      #
      # @param system_prompt [String] The system instruction for the LLM.
      # @param messages [Array<Hash>] The list of conversation messages.
      # @param tools [Array<Hash>] (optional) Array of tool definitions.
      # @param options [Hash] (optional) Additional provider-specific options.
      # @return [Hash] with :success [Boolean] and :response [Hash] keys.
      #   The :response hash contains :message [Hash] on success,
      #   or :error [Hash] with :message [String] on failure.
      # @raise [StandardError] if an unexpected error occurs (rescued internally and logged).
      def self.call(system_prompt:, messages:, tools: [], **options)
        new(system_prompt: system_prompt, messages: messages, tools: tools, **options).call
      end

      # Initializes the client with validated parameters.
      #
      # @param system_prompt [String]
      # @param messages [Array<Hash>]
      # @param tools [Array<Hash>]
      # @param options [Hash]
      def initialize(system_prompt:, messages:, tools: [], **options)
        @system_prompt = system_prompt
        @messages = messages
        @tools = tools
        @api_key = options[:api_key] || Evaluator::Config.api_key
        @model = options[:model] || Evaluator::Config.model
      end

      # Executes the request flow: configuration -> request -> response handling.
      #
      # @return [Hash] Standardized response contract.
      def call
        return config_error unless valid_config?

        response = execute_request
        handle_response(response)
      rescue StandardError => e
        log_error(e)
        { success: false, response: { error: { message: e.message } } }
      end

      protected

      # Abstract method: must return the base URL for the Faraday connection.
      # @return [String]
      def base_url
        raise NotImplementedError
      end

      # Abstract method: must return the path for the API request.
      # @return [String]
      def request_path
        raise NotImplementedError
      end

      # @return [Hash]
      def request_headers
        {
          'Authorization' => "Bearer #{@api_key}",
          'Content-Type' => 'application/json'
        }
      end

      # @return [Hash]
      def request_body
        body = {
          model: @model,
          messages: [{ role: 'system', content: @system_prompt }] + @messages
        }
        body[:tools] = @tools if @tools && !@tools.empty?
        body
      end

      # @return [Boolean]
      def valid_config?
        !!@api_key
      end

      # @return [Hash]
      def config_error
        raise NotImplementedError
      end

      private

      # Sets up Faraday and executes the POST request.
      # @return [Faraday::Response]
      def execute_request
        conn = Faraday.new(url: base_url) do |f|
          f.request :json
          f.response :json
          f.options.open_timeout = 5 # seconds
          f.options.timeout = 10 # seconds
        end

        conn.post(request_path) do |req|
          req.headers.update(request_headers)
          req.body = request_body.to_json
        end
      end

      # Parses the Faraday response into our standardized contract.
      # @param response [Faraday::Response]
      # @return [Hash]
      def handle_response(response)
        return failure_response(response) unless response.success?

        message = extract_message(response.body)
        return missing_message_response(response) if message.nil? || (message.is_a?(Hash) && message.empty?)

        { success: true, response: { message: message } }
      end

      # Returns a standardized failure response when the LLM returns no message.
      # @param _response [Faraday::Response]
      # @return [Hash]
      def missing_message_response(_response)
        { success: false, response: { error: { message: 'LLM response missing message content' } } }
      end

      # Returns a standardized failure response based on the Faraday response.
      # @param response [Faraday::Response]
      # @return [Hash]
      def failure_response(response)
        error_msg = "#{API_FAILED}: #{response.status} - #{response.body}"
        { success: false, response: { error: { message: error_msg } } }
      end

      # Extracts the message hash from the provider's specific response body structure.
      # Default implementation for OpenAI-compatible APIs.
      # @param body [Hash] The parsed JSON response body.
      # @return [Hash]
      def extract_message(body)
        body.dig('choices', 0, 'message')
      end

      # Logs errors according to ruby-service-objects standards.
      # @param error [StandardError]
      def log_error(error)
        message = "#{self.class.name} Error: #{error.message}"
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
