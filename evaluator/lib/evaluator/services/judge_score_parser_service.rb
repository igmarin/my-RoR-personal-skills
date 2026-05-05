# frozen_string_literal: true

require 'json'

module Evaluator
  module Services
    # Service object for parsing judge score responses from evaluation results.
    # Handles JSON strings with optional code blocks, Hash inputs, and provides
    # standardized error handling for malformed data.
    class JudgeScoreParserService
      PARSE_ERROR = 'Failed to parse judge score'

      # Parses a judge score response into a standardized format.
      #
      # @param judge_score [String, Hash, nil] Raw judge score response. Can be:
      #   - A JSON string (with or without markdown code blocks)
      #   - A Hash (with string or symbol keys)
      #   - nil (which will result in an error response)
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: Hash } on success
      #   - { success: false, response: { error: { message: String } } on failure
      def self.call(judge_score)
        new(judge_score).call
      end

      # @param judge_score [String, Hash, nil] Raw judge score response
      def initialize(judge_score)
        @judge_score = judge_score
      end

      # @return [Hash] { success: Boolean, response: Hash }
      def call
        case @judge_score
        when String
          parsed = parse_string_input
          parsed ? { success: true, response: parsed } : error_response
        when Hash
          { success: true, response: @judge_score.transform_keys(&:to_s) }
        else
          error_response
        end
      end

      private

      def error_response
        { success: false, response: { error: { message: PARSE_ERROR } } }
      end

      # @return [Hash, nil] Parsed JSON hash or nil if parsing fails
      def parse_string_input
        cleaned_score = @judge_score.gsub(/\A```json\s*/, '').gsub(/\s*```\z/, '')
        JSON.parse(cleaned_score)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
