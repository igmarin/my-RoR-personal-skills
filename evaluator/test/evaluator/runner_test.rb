# frozen_string_literal: true

require 'test_helper'

module Evaluator
  # Tests for Evaluator::Runner
  class RunnerTest < Minitest::Test
    def setup
      @tmp_dir = Pathname.new(Dir.mktmpdir('evaluator_runner_test'))
      @base_path = @tmp_dir

      create_eval_fixture(
        'evals/skills/patterns/ruby-service-objects/basic-service-object'
      )
      create_eval_fixture(
        'evals/workflows/rails-tdd-loop/full-feature'
      )
    end

    def teardown
      FileUtils.rm_rf(@tmp_dir) if @tmp_dir&.exist?
    end

    def test_call_returns_failure_when_eval_path_does_not_exist
      result = Runner.call(
        eval_folder_path: 'evals/skills/nonexistent/path',
        base_path: @base_path
      )

      refute result[:success]
      assert_match(/does not exist/, result[:response][:error][:message])
    end

    def test_call_infers_source_path_for_skill_evals
      expect_single_task_run(
        source_path: 'skills/patterns/ruby-service-objects'
      )

      result = Runner.call(
        eval_folder_path: 'evals/skills/patterns/ruby-service-objects/basic-service-object',
        base_path: @base_path
      )

      assert result[:success]
      assert_equal 'multiple (batch run)', result[:source_path]
      assert_equal 1, result[:tasks].size
      assert_equal 'skills/patterns/ruby-service-objects', SourcePathResolver.call(eval_folder_path: result[:tasks].first[:path])
    end

    def test_call_infers_source_path_for_workflow_evals
      expect_single_task_run(
        source_path: 'workflows/rails-tdd-loop'
      )

      result = Runner.call(
        eval_folder_path: 'evals/workflows/rails-tdd-loop/full-feature',
        base_path: @base_path
      )

      assert result[:success]
      assert_equal 'multiple (batch run)', result[:source_path]
    end

    def test_call_uses_explicit_source_path_override
      expect_single_task_run(
        source_path: 'skills/patterns/ruby-service-objects'
      )

      result = Runner.call(
        eval_folder_path: 'evals/workflows/rails-tdd-loop/full-feature',
        skill_path: 'skills/patterns/ruby-service-objects',
        base_path: @base_path
      )

      assert result[:success]
      assert_equal 'skills/patterns/ruby-service-objects', result[:source_path]
    end

    def test_call_succeeds_without_context_when_source_path_cannot_be_inferred
      create_eval_fixture('tmp/custom-evals/unmapped-task')

      # Both modes are invoked; we allow at least once to cover baseline and (potential) context
      AgentRunner.expects(:call).at_least_once.returns(%w[output diff])
      Judge.expects(:call).at_least_once.returns('{}')

      result = Runner.call(
        eval_folder_path: 'tmp/custom-evals/unmapped-task',
        base_path: @base_path
      )

      assert result[:success]
      assert_equal 'multiple (batch run)', result[:source_path]
    end

    private

    def create_eval_fixture(relative_path)
      full_path = @base_path.join(relative_path)
      full_path.mkpath
      File.write(full_path.join('task.md'), 'Test task')
      File.write(full_path.join('criteria.json'), '{}')
    end

    def expect_single_task_run(source_path:)
      judge_result = '{"baseline_score":60,"context_score":85,"reasoning":"context is better"}'

      AgentRunner.expects(:call).with(has_entry(mode: :baseline)).returns(
        ['baseline output', 'diff-baseline']
      )
      AgentRunner.expects(:call).with do |params|
        params[:mode] == :context &&
          params[:source_path] == source_path &&
          params[:base_path] == @base_path
      end.returns(['context output', 'diff-context'])
      Judge.expects(:call).returns(judge_result)
    end
  end
end
