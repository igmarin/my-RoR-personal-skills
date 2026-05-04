# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class ReactAgent
    class ToolExecutorTest < Minitest::Test
      def test_call_executes_tools_and_returns_messages
        tool_calls = [
          { 'id' => 'call_1', 'function' => { 'name' => 'read_file', 'arguments' => '{"path":"test.txt"}' } }
        ]

        Tools.expects(:execute).with('read_file', '{"path":"test.txt"}', Dir.pwd).returns('file content')

        result = ToolExecutor.call(tool_calls, Dir.pwd)

        assert_equal 1, result.length
        assert_equal 'tool', result.first[:role]
        assert_equal 'call_1', result.first[:tool_call_id]
        assert_equal 'file content', result.first[:content]
      end
    end
  end
end
