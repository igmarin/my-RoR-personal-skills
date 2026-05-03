# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for the Evaluator::Tools::Registry
    class RegistryTest < Minitest::Test
      def test_definitions
        definitions = Registry.definitions

        assert_equal 3, definitions.length
        assert_equal 'read_file', definitions[0][:function][:name]
        assert_equal 'write_file', definitions[1][:function][:name]
        assert_equal 'run_command', definitions[2][:function][:name]
      end
    end
  end
end
