# frozen_string_literal: true'

require 'stringio'
require 'test_helper'

module Evaluator
  class EvaluateCommandOptionsTest < Minitest::Test
    def setup
      @stdout = StringIO.new
    end

    def test_parse_options_returns_false_for_empty_args
      Evaluator::Services::OptionParserService.stubs(:call).returns(
        { success: false, response: { error: { message: 'Missing required option' } } }
      )
      command = EvaluateCommand.new([], stdout: @stdout)
      result = command.send(:parse_options?)
      refute result
    end

    def test_parse_options_returns_true_for_valid_args
      Runner.stubs(:call).returns(success_result('test'))
      HistoryRecorder.stubs(:record)

      command = EvaluateCommand.new(
        ['--eval', 'evals/skills/example'],
        stdout: @stdout
      )
      result = command.send(:parse_options?)
      assert result
    end

    def test_parse_options_returns_false_when_option_parser_fails
      Evaluator::Services::OptionParserService.stubs(:call).returns(
        { success: false, response: { error: { message: 'Invalid option' } } }
      )
      command = EvaluateCommand.new(['--invalid'], stdout: @stdout)
      result = command.send(:parse_options?)
      refute result
    end

    private

    def success_result(source_path)
      {
        success: true,
        source_path: source_path,
        tasks: []
      }
    end
  end
end
