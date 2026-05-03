# frozen_string_literal: true

require "faraday"
require "json"
require "dotenv/load"

module Evaluator
  class Client
    class Error < StandardError; end

    def initialize(api_key: ENV["OPENAI_API_KEY"], model: "gpt-4o")
      @api_key = api_key
      @model = model

      raise Error, "OPENAI_API_KEY is not set" unless @api_key
    end

    def complete(system_prompt:, prompt:)
      conn = Faraday.new(url: "https://api.openai.com") do |f|
        f.request :json
        f.response :json
      end

      response = conn.post("/v1/chat/completions") do |req|
        req.headers["Authorization"] = "Bearer #{@api_key}"
        req.headers["Content-Type"] = "application/json"
        
        req.body = {
          model: @model,
          messages: [
            { role: "system", content: system_prompt },
            { role: "user", content: prompt }
          ]
        }.to_json
      end

      unless response.success?
        raise Error, "API Request failed: #{response.status} - #{response.body}"
      end

      response.body.dig("choices", 0, "message", "content")
    end
  end
end
