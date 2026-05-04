# frozen_string_literal: true

require 'stringio'
require 'test_helper'

module Evaluator
  class EvaluateCommandTest < Minitest::Test
    def setup
      @stdout = StringIO.new
    end

    def test_call_accepts_eval_without_explicit_skill_override
      Runner.expects(:call).with(has_entries(
                                   eval_folder_path: 'evals/skills/patterns/ruby-service-objects/basic-service-object',
                                   skill_path: nil
                                 )).returns(success_result('skills/patterns/ruby-service-objects'))
      HistoryRecorder.expects(:record).with(
        has_entries(success: true),
        source_path: 'skills/patterns/ruby-service-objects',
        model: Evaluator::Config.model
      )

      exit_code = EvaluateCommand.call(
        %w[--eval evals/skills/patterns/ruby-service-objects/basic-service-object],
        stdout: @stdout
      )

      assert_equal 0, exit_code
    end

    def test_call_passes_explicit_skill_override_through_to_runner
      Runner.expects(:call).with(has_entries(
                                   eval_folder_path: 'evals/workflows/rails-tdd-loop/full-feature',
                                   skill_path: 'skills/patterns/ruby-service-objects'
                                 )).returns(success_result('skills/patterns/ruby-service-objects'))
      HistoryRecorder.expects(:record).with(
        has_entries(success: true),
        source_path: 'skills/patterns/ruby-service-objects',
        model: Evaluator::Config.model
      )

      exit_code = EvaluateCommand.call(
        [
          '--eval', 'evals/workflows/rails-tdd-loop/full-feature',
          '--skill', 'skills/patterns/ruby-service-objects'
        ],
        stdout: @stdout
      )

      assert_equal 0, exit_code
    end

    def test_call_returns_error_when_eval_is_missing
      Runner.expects(:call).never
      HistoryRecorder.expects(:record).never

      exit_code = EvaluateCommand.call([], stdout: @stdout)

      assert_equal 1, exit_code
      assert_match(/--eval option is required/, @stdout.string)
    end

    private

    def success_result(source_path)
      {
        success: true,
        source_path: source_path,
        tasks: []
      }
    end
  end
end
