# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for Evaluator::Tools::RunCommand
    class RunCommandTest < Minitest::Test
      def test_call_executes_command
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path

          result = RunCommand.call('echo test', working_dir)

          assert_match(/STDOUT:\ntest/, result)
          assert_match(/Exit Status: 0/, result)
        end
      end
    end
  end
end
