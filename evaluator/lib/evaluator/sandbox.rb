# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

module Evaluator
  # Manages isolated sandbox environments for running agent evaluations.
  # Handles copying files, initializing git, and capturing diffs.
  # Now supports Docker container isolation for secure command execution.
  class Sandbox
    attr_reader :path, :container_id

    # Runs a block of code within a temporary, isolated sandbox directory.
    # The sandbox is initialized as a git repository and optionally wrapped in a Docker container.
    #
    # @param source_dir [String, Pathname] The directory to copy into the sandbox.
    # @yieldparam sandbox [Evaluator::Sandbox] The sandbox instance.
    # @return [Object] The result of the yielded block.
    # @raise [SystemCallError] when file operations or directory creation fails.
    # @raise [RuntimeError] when Docker commands fail.
    def self.run(source_dir, &)
      new(source_dir).run(&)
    end

    # @param source_dir [String, Pathname] The directory to copy into the sandbox.
    def initialize(source_dir)
      @source_dir = source_dir
      @path = nil
      @container_id = nil
    end

    # Executes the sandbox environment setup and yields the sandbox instance.
    #
    # @yieldparam sandbox [Evaluator::Sandbox] The sandbox instance.
    # @return [Object] The result of the yielded block.
    # @raise [SystemCallError] when file operations or directory creation fails.
    # @raise [RuntimeError] when Docker commands fail.
    def run
      Dir.mktmpdir('evaluator_sandbox_') do |sandbox_dir|
        @path = sandbox_dir
        FileUtils.cp_r(Dir.glob(File.join(@source_dir, '*')), sandbox_dir)

        setup_git

        start_container
        begin
          yield self
        ensure
          stop_container
        end
      end
    end

    # Captures the git diff of changes made within the sandbox.
    #
    # @param sandbox_dir [String] The path to the sandbox directory.
    # @return [String] The git diff, or a message indicating no changes.
    # @raise [SystemCallError] when git commands fail.
    def self.capture_diff(sandbox_dir)
      # Check if we are in a git repo and have at least one commit
      return 'No code changes made.' unless File.directory?(File.join(sandbox_dir, '.git'))

      raise "Failed to stage changes in #{sandbox_dir}" unless system('git', 'add', '.', chdir: sandbox_dir)

      diff, status = Open3.capture2('git', 'diff', '--cached', chdir: sandbox_dir)
      raise "Failed to capture diff in #{sandbox_dir}" unless status.success?

      diff.strip.empty? ? 'No code changes made.' : diff
    end

    private

    def setup_git
      cmds = [
        ['git', 'init', '--quiet'],
        ['git', 'config', 'user.email', 'evaluator@tessl.io'],
        ['git', 'config', 'user.name', 'Evaluator Sandbox'],
        ['git', 'add', '.'],
        ['git', 'commit', '--quiet', '-m', 'Initial commit']
      ]

      cmds.each do |argv|
        raise "Git command failed: #{argv.join(' ')}" unless system(*argv, chdir: @path)
      end
    end

    def start_container
      image_name = 'evaluator-sandbox'
      docker_dir = File.expand_path('docker', __dir__)

      # Build image if missing
      raise "Failed to build Docker image #{image_name}" unless system('docker', 'build', '-t', image_name, docker_dir, '--quiet')

      # Start a detached container mounting the sandbox dir to /sandbox
      stdout, stderr, status = Open3.capture3(
        'docker', 'run', '-d', '--rm', '-v', "#{@path}:/sandbox", image_name
      )

      raise "Failed to start Docker container: #{stderr}" unless status.success?

      @container_id = stdout.strip
    end

    def stop_container
      return unless @container_id

      # Stop and remove the container (it's --rm so stopping also removes it)
      # We don't fail-fast on stop to avoid swallowing the original error if this is in an ensure block
      system('docker', 'stop', @container_id, out: File::NULL, err: File::NULL)
    end
  end
end
