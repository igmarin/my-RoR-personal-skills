# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module Evaluator
  # Manages isolated sandbox environments for running agent evaluations.
  # Handles copying files, initializing git, and capturing diffs.
  class Sandbox
    # Runs a block of code within a temporary, isolated sandbox directory.
    # The sandbox is initialized as a git repository to track changes.
    #
    # @param source_dir [String, Pathname] The directory to copy into the sandbox.
    # @yieldparam sandbox_dir [String] The path to the temporary sandbox directory.
    # @return [Object] The result of the yielded block.
    def self.run(source_dir, &)
      new(source_dir).run(&)
    end

    # @param source_dir [String, Pathname] The directory to copy into the sandbox.
    def initialize(source_dir)
      @source_dir = source_dir
    end

    # Executes the sandbox environment setup and yields the directory.
    #
    # @yieldparam sandbox_dir [String] The path to the temporary sandbox directory.
    # @return [Object] The result of the yielded block.
    def run
      Dir.mktmpdir('evaluator_sandbox_') do |sandbox_dir|
        FileUtils.cp_r(Dir.glob("#{@source_dir}/*"), sandbox_dir)

        system('git init --quiet', chdir: sandbox_dir)
        system('git add .', chdir: sandbox_dir)
        system("git commit --quiet -m 'Initial commit'", chdir: sandbox_dir)

        yield sandbox_dir
      end
    end

    # Captures the git diff of changes made within the sandbox.
    #
    # @param sandbox_dir [String] The path to the sandbox directory.
    # @return [String] The git diff, or a message indicating no changes.
    def self.capture_diff(sandbox_dir)
      system('git add .', chdir: sandbox_dir)
      diff = `cd #{sandbox_dir} && git diff --cached`
      diff.strip.empty? ? 'No code changes made.' : diff
    end
  end
end
