# frozen_string_literal: true

require 'faraday'
require 'json'
require 'dotenv/load'
require_relative 'config'

module Evaluator
  # Handles communication with the OpenAI API.
  # Wraps requests to the chat completion endpoint and parses responses.
  class Client
    API_FAILED = 'API Request failed'

    # Sends a chat completion request to the API.
    #
    # @param params [Hash] The configuration for the API call.
    # @option params [String] :system_prompt The system instruction for the LLM.
    # @option params [Array<Hash>] :messages The list of conversation messages.
    # @option params [Array<Hash>] :tools (optional) Array of tool definitions the model can use.
    # @option params [String] :api_key (optional) The API key to use. Falls back to Config.openai_api_key.
    # @option params [String] :model (optional) The model name to use. Defaults to Config.model.
    # @return [Hash] A hash containing `:success` (Boolean) and `:response` (Hash).
    def self.call(params)
      new(params).call
    end

    # @param params [Hash] The configuration for the API call.
    def initialize(params)
      @api_key = params[:api_key] || Evaluator::Config.openai_api_key
      @model = params[:model] || Evaluator::Config.model
      @system_prompt = params[:system_prompt]
      @messages = params[:messages]
      @tools = params[:tools]
    end

    # Executes the HTTP request.
    #
    # @return [Hash] The standardized result hash indicating success or failure.
    def call
      return { success: false, response: { error: { message: 'OPENAI_API_KEY is not set' } } } unless @api_key

      conn = Faraday.new(url: 'https://api.openai.com') do |f|
        f.request :json
        f.response :json
      end

      body = {
        model: @model,
        messages: [{ role: 'system', content: @system_prompt }] + @messages
      }
      body[:tools] = @tools if @tools && !@tools.empty?

      response = conn.post('/v1/chat/completions') do |req|
        req.headers['Authorization'] = "Bearer #{@api_key}"
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end

      unless response.success?
        error_msg = "#{API_FAILED}: #{response.status} - #{response.body}"
        return { success: false, response: { error: { message: error_msg } } }
      end

      message = response.body.dig('choices', 0, 'message')
      { success: true, response: { message: message } }
    rescue StandardError => e
      Rails.logger.error("Client Error: #{e.message}") if defined?(Rails)
      { success: false, response: { error: { message: e.message } } }
    end
  end
end
