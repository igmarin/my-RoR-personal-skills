# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for the Evaluator::Tools::Dispatcher
    class DispatcherTest < Minitest::Test
      def test_execute_read_file
        Evaluator::Tools::ReadFile.expects(:call).with('test.txt', anything).returns('file content')
        result = Dispatcher.call('read_file', '{"path":"test.txt"}', Dir.pwd, nil)

        assert_equal 'file content', result
      end

      def test_execute_write_file
        Evaluator::Tools::WriteFile.expects(:call).with('new_file.txt', 'New text', anything).returns('success')
        result = Dispatcher.call('write_file', '{"path":"new_file.txt", "content":"New text"}', Dir.pwd, nil)

        assert_equal 'success', result
      end

      def test_execute_run_command
        Evaluator::Tools::RunCommand.expects(:call).with('echo test', anything, nil).returns('command output')
        result = Dispatcher.call('run_command', '{"command":"echo test"}', Dir.pwd, nil)

        assert_equal 'command output', result
      end

      def test_execute_unknown_tool
        result = Dispatcher.call('unknown', '{}', Dir.pwd)

        assert_equal "Error: Unknown tool 'unknown'", result
      end

      def test_execute_rescues_standard_error
        Evaluator::Tools::ReadFile.expects(:call).raises(StandardError, 'Oops')
        result = Dispatcher.call('read_file', '{"path":"test.txt"}', Dir.pwd, nil)

        assert_equal 'Error executing tool: Oops', result
      end
    end
  end
end
