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
    # Mock Docker to avoid running real containers in unit tests
    Evaluator::Sandbox.any_instance.stubs(:start_container)
    Evaluator::Sandbox.any_instance.stubs(:stop_container)

    Evaluator::Sandbox.run(@source_dir) do |sandbox|
      assert_path_exists File.join(sandbox.path, 'test_file.txt')
      assert_path_exists File.join(sandbox.path, '.git')

      # Test diff is empty initially
      diff = Evaluator::Sandbox.capture_diff(sandbox.path)

      assert_equal 'No code changes made.', diff

      # Make a change
      File.write(File.join(sandbox.path, 'test_file.txt'), 'hello updated')
      diff = Evaluator::Sandbox.capture_diff(sandbox.path)

      assert_includes diff, 'hello updated'
    end
  end
end
