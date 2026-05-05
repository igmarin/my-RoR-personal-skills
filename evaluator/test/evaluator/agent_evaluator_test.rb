# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class AgentEvaluatorTest < Minitest::Test
    def test_module_is_defined
      assert defined?(Evaluator)
      assert_kind_of Module, Evaluator
    end

    def test_version_is_accessible
      assert defined?(Evaluator::VERSION)
      assert_equal '0.0.1', Evaluator::VERSION
    end

    def test_module_is_already_loaded
      # The module should already be loaded by test_helper
      assert defined?(Evaluator)
    end
  end
end
