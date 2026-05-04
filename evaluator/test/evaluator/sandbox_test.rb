# frozen_string_literal: true

require_relative '../test_helper'
require 'fileutils'
require 'tmpdir'

class SandboxTest < Minitest::Test
  def setup
    @source_dir = Dir.mktmpdir('evaluator_test_source_')
    File.write(File.join(@source_dir, 'test_file.txt'), 'hello world')
  end

  def teardown
    FileUtils.rm_rf(@source_dir)
  end

  def test_run_copies_files_and_initializes_git
    Evaluator::Sandbox.run(@source_dir) do |sandbox_dir|
      assert_path_exists File.join(sandbox_dir, 'test_file.txt')
      assert_path_exists File.join(sandbox_dir, '.git')

      # Test diff is empty initially
      diff = Evaluator::Sandbox.capture_diff(sandbox_dir)

      assert_equal 'No code changes made.', diff

      # Make a change
      File.write(File.join(sandbox_dir, 'test_file.txt'), 'hello updated')
      diff = Evaluator::Sandbox.capture_diff(sandbox_dir)

      assert_includes diff, 'hello updated'
    end
  end
end
