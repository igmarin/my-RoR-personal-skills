# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'pathname'

module Evaluator
  module Tools
    class ReadFileTest < Minitest::Test
      def setup
        @tmpdir = Dir.mktmpdir
        @working_dir = Pathname.new(@tmpdir).realpath
        @test_file = @working_dir.join('test.txt')
        @test_file.write('hello world')
      end

      def teardown
        FileUtils.remove_entry @tmpdir
      end

      def test_read_valid_file
        result = ReadFile.call('test.txt', @working_dir)

        assert_equal 'hello world', result
      end

      def test_path_traversal_prevention
        error = assert_raises(ArgumentError) do
          ReadFile.call('../outside.txt', @working_dir)
        end
        assert_match(/Path traversal attempt/, error.message)
      end

      def test_file_not_found
        result = ReadFile.call('nonexistent.txt', @working_dir)

        assert_equal 'Error: File not found', result
      end
    end
  end
end
