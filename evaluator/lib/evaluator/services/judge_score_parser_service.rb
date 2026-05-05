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
      #   - { success: false, response: { error: { message: String } } } on failure
      # @example Parse a JSON string
      #   result = JudgeScoreParserService.call('{"baseline_score": 80, "context_score": 90}')
      #   # => { success: true, response: { "baseline_score" => 80, "context_score" => 90 } }
      # @example Parse a string with code blocks
      #   result = JudgeScoreParserService.call('```json{"score": 85}```')
      #   # => { success: true, response: { "score" => 85 } }
      # @example Parse a hash
      #   result = JudgeScoreParserService.call({ baseline_score: 75 })
      #   # => { success: true, response: { "baseline_score" => 75 } }
      def self.call(judge_score)
        new(judge_score).call
      end

      # Initializes a new parser instance.
      #
      # @param judge_score [String, Hash, nil] Raw judge score response
      def initialize(judge_score)
        @judge_score = judge_score
      end

      # Processes the judge score and returns a standardized response.
      #
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: Hash } on success
      #   - { success: false, response: { error: { message: String } } } on failure
      # @raise [JSON::ParserError] when JSON string cannot be parsed (handled internally)
      def call
        return { success: false, response: { error: { message: PARSE_ERROR } } } if @judge_score.nil?

        parsed = case @judge_score
                 when String
                   parse_string_input
                 when Hash
                   @judge_score.transform_keys(&:to_s)
                 end

        return { success: false, response: { error: { message: PARSE_ERROR } } } if parsed.nil?

        { success: true, response: parsed }
      end

      private

      # Parses a string input, removing markdown code blocks if present.
      #
      # @return [Hash, nil] Parsed JSON hash or nil if parsing fails
      # @raise [JSON::ParserError] when JSON string cannot be parsed (handled internally)
      def parse_string_input
        cleaned_score = @judge_score.gsub(/\A```json\s*/, '').gsub(/\s*```\z/, '')
        JSON.parse(cleaned_score)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
