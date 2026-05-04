# frozen_string_literal: true

require 'test_helper'
require 'tools/write_file'
require 'tools/read_file'

module Evaluator
  module Tools
    class SecurityTest < Minitest::Test
      def setup
        @working_dir = Pathname.new(Dir.mktmpdir)
      end

      def teardown
        @working_dir.rmtree
      end

      def test_write_file_allows_separators
        result = WriteFile.call('subdir/file.txt', 'content', @working_dir)

        assert_match(/Successfully wrote/, result)
        assert_equal 'content', File.read(@working_dir.join('subdir/file.txt'))
      end

      def test_write_file_disallows_traversal
        assert_raises(ArgumentError) do
          WriteFile.call('../outside.txt', 'content', @working_dir)
        end
      end

      def test_write_file_disallows_multiple_dots
        assert_raises(ArgumentError) do
          WriteFile.call('file.test.txt', 'content', @working_dir)
        end
      end

      def test_write_file_allows_simple_filename
        result = WriteFile.call('safe.txt', 'content', @working_dir)

        assert_match(/Successfully wrote/, result)
        assert_equal 'content', File.read(@working_dir.join('safe.txt'))
      end
    end
  end
end
