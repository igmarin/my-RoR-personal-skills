# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class ReactAgent
    class StepTest < Minitest::Test
      def setup
        @config = {
          system_prompt: 'System',
          client_params: {},
          working_dir: Dir.pwd
        }
        @messages = [{ role: 'user', content: 'Initial' }]
      end

      def test_call_returns_continue_false_on_client_failure
        Client.expects(:call).returns({ success: false, response: { error: { message: 'API Error' } } })

        result = Step.call(@messages, @config)

        refute result[:continue]
        refute result[:result][:success]
        assert_equal 'API Error', result[:result][:response][:error][:message]
      end

      def test_call_returns_continue_false_when_no_tool_calls
        Client.expects(:call).returns(
          { success: true, response: { message: { 'content' => 'Final Answer', 'tool_calls' => [] } } }
        )

        result = Step.call(@messages, @config)

        refute result[:continue]
        assert result[:result][:success]
        assert_equal 'Final Answer', result[:result][:response][:content]
      end

      def test_call_returns_continue_true_and_executes_tools
        Client.expects(:call).returns(
          {
            success: true,
            response: {
              message: {
                'content' => 'Thinking...',
                'tool_calls' => [{ 'id' => 'call_1', 'function' => { 'name' => 'read_file', 'arguments' => '{"path":"a"}' } }]
              }
            }
          }
        )

        ToolExecutor.expects(:call).returns([{ role: 'tool', tool_call_id: 'call_1', content: 'result' }])

        result = Step.call(@messages, @config)

        assert result[:continue]
        assert_equal 3, result[:messages].length # user, assistant, tool
        assert_equal 'tool', result[:messages].last[:role]
        assert_equal 'result', result[:messages].last[:content]
      end
    end
  end
end
