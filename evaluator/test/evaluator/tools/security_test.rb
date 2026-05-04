# frozen_string_literal: true

require 'test_helper'
require 'tools/write_file'
require 'tools/read_file'

module Evaluator
  module Tools
    class SecurityTest < Minitest::Test
      def setup
        @working_dir = Pathname.new(Dir.mktmpdir).realpath
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

      def test_write_file_allows_multiple_dots
        # Multiple dots are now allowed (e.g., .github/workflows/main.yml, hidden.test.txt)
        result = WriteFile.call('.hidden/file.test.txt', 'content', @working_dir)

        assert_match(/Successfully wrote/, result)
        assert_equal 'content', File.read(@working_dir.join('.hidden/file.test.txt'))
      end

      def test_write_file_allows_simple_filename
        result = WriteFile.call('safe.txt', 'content', @working_dir)

        assert_match(/Successfully wrote/, result)
        assert_equal 'content', File.read(@working_dir.join('safe.txt'))
      end

      def test_read_file_allows_subdirectories_and_multiple_dots
        # Create file first
        subdir = @working_dir.join('.github/workflows')
        subdir.mkpath
        target = subdir.join('main.ci.yml')
        File.write(target, 'test content')

        result = ReadFile.call('.github/workflows/main.ci.yml', @working_dir)

        assert_match(/test content/, result)
      end

      def test_secure_path_prevents_prefix_bypass
        # Base path: /tmp/sandbox
        # Requested path: ../sandbox-escaped/file.txt
        # Ensure it doesn't allow it just because it starts with "/tmp/sandbox"

        sandbox_name = @working_dir.basename.to_s
        escaped_dir = Pathname.new("#{@working_dir}-escaped")
        escaped_dir.mkpath
        begin
          error = assert_raises(ArgumentError) do
            Base.send(:secure_path, "../#{sandbox_name}-escaped/file.txt", @working_dir)
          end
          assert_match(/Path traversal attempt/, error.message)
        ensure
          escaped_dir.rmtree if escaped_dir.exist?
        end
      end

      def test_verify_symlink_safety_prevents_escape
        subdir = @working_dir.join('safe_dir')
        subdir.mkpath

        # Create an external directory
        external_dir = Pathname.new(Dir.mktmpdir).realpath

        begin
          # Create a symlink pointing outside the working directory
          symlink_path = subdir.join('symlink_to_external')
          File.symlink(external_dir.to_s, symlink_path.to_s)

          # Attempting to read or write through the symlink should fail
          assert_raises(ArgumentError) do
            Base.send(:secure_path, 'safe_dir/symlink_to_external/file.txt', @working_dir)
          end
        ensure
          external_dir.rmtree if external_dir.exist?
        end
      end

      def test_verify_symlink_safety_rejects_dangling_symlink
        subdir = @working_dir.join('safe_dir')
        subdir.mkpath

        # Create a dangling symlink
        dangling_symlink = subdir.join('broken_link')
        File.symlink('/does/not/exist/literally/anywhere', dangling_symlink.to_s)

        error = assert_raises(ArgumentError) do
          Base.send(:secure_path, 'safe_dir/broken_link/file.txt', @working_dir)
        end
        assert_match(/Dangling symlink/, error.message)
      end
    end
  end
end
