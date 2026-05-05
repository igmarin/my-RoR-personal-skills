# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for Evaluator::Tools::RunCommand
    class RunCommandTest < Minitest::Test
      def setup
        # Reset config to allow all commands
        Evaluator::Config.reset
      end

      def test_call_executes_command
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path

          result = RunCommand.call('echo test', working_dir)

          assert_match(/STDOUT:\ntest/, result)
          assert_match(/Exit Status: 0/, result)
        end
      end

      def test_call_executes_in_container
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path
          container_id = 'mock-container-id'

          # Mock Open3.capture3 to verify docker call
          status = mock('Process::Status')
          status.stubs(:exitstatus).returns(0)
          Open3.expects(:capture3).with('docker', 'exec', '-w', '/sandbox', container_id, 'echo', 'test').returns(['test', '', status])

          result = RunCommand.call('echo test', working_dir, container_id)

          assert_match(/STDOUT:\ntest/, result)
          assert_match(/Exit Status: 0/, result)
        end
      end
    end
  end
end
