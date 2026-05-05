# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class LoopRunnerTest < Minitest::Test
    def test_call_returns_success_when_agent_completes
      # Arrange
      Client.expects(:call).returns(
        { success: true, response: { message: { 'content' => 'Final Answer' } } }
      )

      # Act
      result = ReactAgent::LoopRunner.call('Initial', 10, { client_params: {} })

      # Assert
      assert result[:success]
      assert_equal 'Final Answer', result[:response][:content]
    end

    def test_call_executes_tools_and_loops
      # Arrange
      Client.expects(:call).twice.returns(
        {
          success: true,
          response: {
            message: {
              'content' => 'Thinking...',
              'tool_calls' => [{ 'id' => 'call_1', 'function' => { 'name' => 'run_command', 'arguments' => '{"command":"echo 1"}' } }]
            }
          }
        }
      ).then.returns(
        { success: true, response: { message: { 'content' => 'Final Answer after tool' } } }
      )

      Tools.expects(:execute).with('run_command', '{"command":"echo 1"}', anything, nil).returns('Tool Result')

      # Act
      result = ReactAgent::LoopRunner.call('Initial', 10, { working_dir: Dir.pwd, client_params: {} })

      # Assert
      assert result[:success]
      assert_equal 'Final Answer after tool', result[:response][:content]
    end

    def test_call_returns_error_on_max_iterations
      # Arrange
      Client.stubs(:call).returns(
        {
          success: true,
          response: {
            message: {
              'content' => 'Thinking...',
              'tool_calls' => [{ 'id' => 'call_1', 'function' => { 'name' => 'run_command', 'arguments' => '{"command":"echo 1"}' } }]
            }
          }
        }
      )

      Tools.stubs(:execute).returns('Tool Result')

      # Act
      result = ReactAgent::LoopRunner.call('Initial', 2, { working_dir: Dir.pwd, client_params: {} })

      # Assert
      refute result[:success]
      assert_match(/Reached max iterations/, result[:response][:error][:message])
    end
  end
end
