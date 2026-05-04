# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'pathname'

module Evaluator
  module Tools
    class WriteFileTest < Minitest::Test
      def setup
        @tmpdir = Dir.mktmpdir
        @working_dir = Pathname.new(@tmpdir).realpath
      end

      def teardown
        FileUtils.remove_entry @tmpdir
      end

      def test_write_valid_file
        result = WriteFile.call('test.txt', 'new content', @working_dir)

        assert_equal 'Successfully wrote to test.txt', result
        assert_equal 'new content', File.read(@working_dir.join('test.txt'))
      end

      def test_path_traversal_prevention
        error = assert_raises(ArgumentError) do
          WriteFile.call('../outside.txt', 'hacked', @working_dir)
        end
        assert_match(/Path traversal attempt/, error.message)
      end

      def test_nested_directory_creation
        result = WriteFile.call('subdir/file.txt', 'content', @working_dir)

        assert_equal 'Successfully wrote to subdir/file.txt', result
        assert_equal 'content', File.read(@working_dir.join('subdir/file.txt'))
      end
    end
  end
end
