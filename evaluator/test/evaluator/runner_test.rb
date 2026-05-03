# frozen_string_literal: true

require 'test_helper'

module Evaluator
  # Tests for Evaluator::Runner
  class RunnerTest < Minitest::Test
    def setup
      @skill_path  = 'skills/patterns/ruby-service-objects'
      @base_path   = Pathname.new(File.expand_path('../../../..', __dir__))
      @tmp_dir     = Dir.mktmpdir
      @eval_path   = Pathname.new(@tmp_dir).relative_path_from(@base_path).to_s
      @full_eval_path = @base_path.join(@eval_path)

      # Create required files for the eval path
      File.write(@full_eval_path.join('task.md'), 'Test task')
      File.write(@full_eval_path.join('criteria.json'), '{}')
    end

    def teardown
      FileUtils.rm_rf(@tmp_dir) if @tmp_dir && Dir.exist?(@tmp_dir)
    end

    def test_call_returns_failure_when_eval_path_does_not_exist
      result = Runner.call(
        eval_folder_path: 'evals/skills/nonexistent/path',
        skill_path: @skill_path,
        base_path: @base_path
      )

      refute result[:success]
      assert_match(/does not exist/, result[:response][:error][:message])
    end

    def test_call_delegates_to_agent_runner_and_judge
      judge_result = '{"baseline_score":60,"context_score":85,"reasoning":"context is better"}'

      # Use sequence of returns for the two calls (baseline then context)
      AgentRunner.stubs(:call).returns(
        ['baseline output', 'diff-baseline'],
        ['context output', 'diff-context']
      )
      Judge.stubs(:call).returns(judge_result)

      result = Runner.call(
        eval_folder_path: @eval_path,
        skill_path: @skill_path,
        base_path: @base_path
      )

      assert result[:success]
      assert_equal 1, result[:tasks].size
      task_result = result[:tasks].first

      assert_equal 'diff-baseline', task_result[:baseline_diff]
      assert_equal 'diff-context',  task_result[:context_diff]
      assert_equal judge_result,    task_result[:judge_score]
    end

    def test_call_returns_failure_on_unexpected_error
      AgentRunner.stubs(:call).raises('boom')
      result = Runner.call(
        eval_folder_path: @eval_path,
        skill_path: @skill_path,
        base_path: @base_path
      )

      refute result[:success]
      assert_equal 'boom', result[:response][:error][:message]
    end
  end
end
