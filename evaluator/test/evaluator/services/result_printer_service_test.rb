# frozen_string_literal: true

require 'test_helper'
require 'stringio'

module Evaluator
  module Services
    class ResultPrinterServiceTest < Minitest::Test
      def setup
        @stdout = StringIO.new
        @success_result = {
          success: true,
          tasks: [
            {
              path: 'test/task1',
              judge_score: {
                'baseline_score' => 80,
                'context_score' => 90,
                'reasoning' => 'Good work on task 1'
              },
              baseline_diff: 'diff1',
              context_diff: 'diff2'
            },
            {
              path: 'test/task2',
              judge_score: {
                baseline_score: 85,
                context_score: 95,
                reasoning: 'Excellent work on task 2'
              },
              baseline_diff: 'diff3',
              context_diff: 'diff4'
            }
          ]
        }
        @failure_result = {
          success: false,
          response: { error: { message: 'Test error' } }
        }
      end

      def test_call_with_successful_result
        result = ResultPrinterService.call(@success_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'RESULTS'
        assert_includes output, 'test/task1'
        assert_includes output, 'test/task2'
        assert_includes output, 'Baseline Score: 80/100'
      end

      def test_call_with_successful_result_shows_scores
        result = ResultPrinterService.call(@success_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'Context Score:  90/100'
        assert_includes output, 'Good work on task 1'
        assert_includes output, 'BASELINE CHANGES'
        assert_includes output, 'CONTEXT CHANGES'
      end

      def test_call_with_successful_result_shows_diffs
        result = ResultPrinterService.call(@success_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'diff1'
      end

      def test_call_with_successful_result_shows_second_diff
        result = ResultPrinterService.call(@success_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'diff2'
      end

      def test_call_with_failure_result
        result = ResultPrinterService.call(@failure_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'RESULTS'
        assert_includes output, 'Evaluation failed: Test error'
        refute_includes output, 'test/task'
      end

      def test_call_with_nil_judge_score
        task_with_nil_score = {
          path: 'test/task',
          judge_score: nil,
          baseline_diff: 'diff1',
          context_diff: 'diff2'
        }
        result_with_nil_score = {
          success: true,
          tasks: [task_with_nil_score]
        }

        result = ResultPrinterService.call(result_with_nil_score, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'Could not parse judge JSON response'
        assert_includes output, 'nil'
      end
    end

    class ResultPrinterServiceEdgeCasesTest < Minitest::Test
      def setup
        @stdout = StringIO.new
      end

      def test_call_with_invalid_judge_score
        task_with_invalid_score = {
          path: 'test/task',
          judge_score: 'invalid json',
          baseline_diff: 'diff1',
          context_diff: 'diff2'
        }
        result_with_invalid_score = {
          success: true,
          tasks: [task_with_invalid_score]
        }

        result = ResultPrinterService.call(result_with_invalid_score, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'Could not parse judge JSON response'
        assert_includes output, 'invalid json'
      end

      def test_call_with_empty_tasks
        empty_result = {
          success: true,
          tasks: []
        }

        result = ResultPrinterService.call(empty_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'RESULTS'
        refute_includes output, 'test/task'
      end

      def test_call_with_string_judge_score_with_code_blocks
        task_with_string_score = {
          path: 'test/task',
          judge_score: '```json
{
  "baseline_score": 75,
  "context_score": 85,
  "reasoning": "Good work"
}
```',
          baseline_diff: 'diff1',
          context_diff: 'diff2'
        }
        result_with_string_score = {
          success: true,
          tasks: [task_with_string_score]
        }

        result = ResultPrinterService.call(result_with_string_score, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        assert_includes output, 'Baseline Score: 75/100'
        assert_includes output, 'Context Score:  85/100'
        assert_includes output, 'Good work'
      end

      def test_call_defaults_to_stdout
        success_result = {
          success: true,
          tasks: []
        }

        result = ResultPrinterService.call(success_result)

        assert result[:success]
        # Should not raise any errors when using default stdout
      end

      def test_call_preserves_output_formatting
        success_result = {
          success: true,
          tasks: [
            {
              path: 'test/task1',
              judge_score: { 'baseline_score' => 80, 'context_score' => 90, 'reasoning' => 'test' },
              baseline_diff: 'diff1',
              context_diff: 'diff2'
            }
          ]
        }

        result = ResultPrinterService.call(success_result, stdout: @stdout)

        assert result[:success]
        output = @stdout.string

        # Check for the specific formatting separators
        assert_includes output, '========================================='
        assert_includes output, 'RESULTS: test/task1'
        assert_includes output, 'BASELINE CHANGES: test/task1'
        assert_includes output, 'CONTEXT CHANGES: test/task1'
      end
    end
  end
end
