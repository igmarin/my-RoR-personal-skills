# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for the Evaluator::Tools::ArgumentParser
    class ArgumentParserTest < Minitest::Test
      def test_valid_json
        result = ArgumentParser.call('{"key": "value"}')

        assert_equal({ 'key' => 'value' }, result)
      end

      def test_invalid_json
        result = ArgumentParser.call('invalid json')

        assert_match(/Error executing tool: Invalid JSON format/, result)
      end
    end
  end
end
