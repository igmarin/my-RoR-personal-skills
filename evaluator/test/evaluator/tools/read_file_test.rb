# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for Evaluator::Tools::ReadFile
    class ReadFileTest < Minitest::Test
      def test_call_reads_file
        Dir.mktmpdir do |dir|
          File.write(File.join(dir, 'test.txt'), 'Hello world')
          working_dir = Pathname.new(dir).expand_path

          result = ReadFile.call('test.txt', working_dir)

          assert_equal 'Hello world', result
        end
      end

      def test_call_returns_error_for_missing_file
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path

          result = ReadFile.call('missing.txt', working_dir)

          assert_equal 'Error: File not found', result
        end
      end
    end
  end
end
