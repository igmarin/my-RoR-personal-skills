# frozen_string_literal: true

require 'test_helper'

module Evaluator
  # Tests for the Evaluator::Tools routing module
  class ToolsTest < Minitest::Test
    def test_definitions_delegates_to_registry
      Tools::Registry.expects(:definitions).returns([])

      assert_equal [], Tools.definitions
    end

    def test_execute_delegates_to_dispatcher
      Tools::Dispatcher.expects(:call).with('read_file', '{}', '/tmp').returns('result')

      assert_equal 'result', Tools.execute('read_file', '{}', '/tmp')
    end
  end
end
