# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Services
    class JudgeScoreParserServiceTest < Minitest::Test
      def test_call_with_json_string
        json_string = '{"baseline_score": 80, "context_score": 90, "reasoning": "Good work"}'

        result = Evaluator::Services::JudgeScoreParserService.call(json_string)

        assert result[:success]
        assert_equal 80, result[:response]['baseline_score']
        assert_equal 90, result[:response]['context_score']
        assert_equal 'Good work', result[:response]['reasoning']
      end

      def test_call_with_json_string_and_code_blocks
        json_string = '```json
{
  "baseline_score": 75,
  "context_score": 85,
  "reasoning": "Well done"
}
```'

        result = Evaluator::Services::JudgeScoreParserService.call(json_string)

        assert result[:success]
        assert_equal 75, result[:response]['baseline_score']
        assert_equal 85, result[:response]['context_score']
        assert_equal 'Well done', result[:response]['reasoning']
      end

      def test_call_with_hash_input
        hash_input = { 'baseline_score' => 70, 'context_score' => 80, 'reasoning' => 'Needs improvement' }

        result = Evaluator::Services::JudgeScoreParserService.call(hash_input)

        assert result[:success]
        assert_equal 70, result[:response]['baseline_score']
        assert_equal 80, result[:response]['context_score']
        assert_equal 'Needs improvement', result[:response]['reasoning']
      end

      def test_call_with_symbol_keys_hash
        hash_input = { baseline_score: 70, context_score: 80, reasoning: 'Needs improvement' }

        result = Evaluator::Services::JudgeScoreParserService.call(hash_input)

        assert result[:success]
        assert_equal 70, result[:response]['baseline_score']
        assert_equal 80, result[:response]['context_score']
        assert_equal 'Needs improvement', result[:response]['reasoning']
      end

      def test_call_with_invalid_json_string
        invalid_json = '{"invalid": json}'

        result = Evaluator::Services::JudgeScoreParserService.call(invalid_json)

        refute result[:success]
        assert_includes result[:response][:error][:message], 'Failed to parse judge score'
      end

      def test_call_with_nil_input
        result = Evaluator::Services::JudgeScoreParserService.call(nil)

        refute result[:success]
        assert_includes result[:response][:error][:message], 'Failed to parse judge score'
      end

      def test_call_with_empty_string
        result = Evaluator::Services::JudgeScoreParserService.call('')

        refute result[:success]
        assert_includes result[:response][:error][:message], 'Failed to parse judge score'
      end

      def test_call_with_non_json_string
        result = Evaluator::Services::JudgeScoreParserService.call('just plain text')

        refute result[:success]
        assert_includes result[:response][:error][:message], 'Failed to parse judge score'
      end
    end
  end
end
