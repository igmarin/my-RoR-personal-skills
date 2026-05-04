# frozen_string_literal: true

require_relative '../test_helper'

class JudgeTest < Minitest::Test
  def test_call_sends_correct_prompt_to_client
    task = 'do something'
    criteria = '{"score": "1-100"}'
    baseline_diff = '+ baseline code'
    context_diff = '+ context code'

    expected_response = { success: true, response: { message: { 'content' => '{"baseline_score": 80, "context_score": 90, "reasoning": "better context"}' } } }

    Evaluator::Client.expects(:call).with do |params|
      params[:system_prompt].include?('objective judge') &&
        params[:messages].first[:content].include?('<baseline_code_diff>')
    end.returns(expected_response)

    result = Evaluator::Judge.call(task, criteria, baseline_diff, context_diff)

    assert_equal '{"baseline_score": 80, "context_score": 90, "reasoning": "better context"}', result
  end

  def test_call_returns_error_on_client_failure
    Evaluator::Client.expects(:call).returns({ success: false, response: { error: { message: 'API failure' } } })

    result = Evaluator::Judge.call('task', 'criteria', 'diff1', 'diff2')

    assert_equal 'Error running judge: API failure', result
  end
end
