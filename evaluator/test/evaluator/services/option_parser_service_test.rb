# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Services
    class OptionParserServiceTest < Minitest::Test
      def test_call_with_valid_arguments
        argv = %w[-e evals/skills/test -s skills/override -o output.json]

        result = OptionParserService.call(argv)

        assert result[:success]
        assert_equal 'evals/skills/test', result[:response][:eval]
        assert_equal 'skills/override', result[:response][:skill]
        assert_equal 'output.json', result[:response][:output]
      end

      def test_call_with_minimal_arguments
        argv = %w[-e evals/skills/test]

        result = OptionParserService.call(argv)

        assert result[:success]
        assert_equal 'evals/skills/test', result[:response][:eval]
        assert_nil result[:response][:skill]
        assert_nil result[:response][:output]
      end

      def test_call_with_empty_arguments
        argv = []

        result = OptionParserService.call(argv)

        assert result[:success]
        assert_empty result[:response]
      end

      def test_call_with_invalid_flag
        argv = %w[--invalid-flag]

        result = OptionParserService.call(argv)

        refute result[:success]
        assert_includes result[:response][:error][:message], 'invalid option'
      end

      def test_call_with_help_flag
        argv = %w[-h]

        assert_raises(SystemExit) do
          OptionParserService.call(argv)
        end
      end

      def test_call_with_long_form_flags
        argv = %w[--eval evals/test --skill skills/test --output out.json]

        result = OptionParserService.call(argv)

        assert result[:success]
        assert_equal 'evals/test', result[:response][:eval]
        assert_equal 'skills/test', result[:response][:skill]
        assert_equal 'out.json', result[:response][:output]
      end
    end
  end
end
