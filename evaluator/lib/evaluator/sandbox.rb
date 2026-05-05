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
    def run
      Dir.mktmpdir('evaluator_sandbox_') do |sandbox_dir|
        @path = sandbox_dir
        FileUtils.cp_r(Dir.glob("#{@source_dir}/*"), sandbox_dir)

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
    def self.capture_diff(sandbox_dir)
      # Check if we are in a git repo and have at least one commit
      return 'No code changes made.' unless File.directory?(File.join(sandbox_dir, '.git'))

      system('git add .', chdir: sandbox_dir)
      diff = `cd #{sandbox_dir} && git diff --cached`
      diff.strip.empty? ? 'No code changes made.' : diff
    end

    private

    def setup_git
      system('git init --quiet', chdir: @path)
      system('git config user.email "evaluator@tessl.io"', chdir: @path)
      system('git config user.name "Evaluator Sandbox"', chdir: @path)
      system('git add .', chdir: @path)
      system("git commit --quiet -m 'Initial commit'", chdir: @path)
    end

    def start_container
      image_name = 'evaluator-sandbox'
      # Build image if missing (fast if already built)
      docker_dir = File.expand_path('docker', __dir__)
      system("docker build -t #{image_name} #{docker_dir} --quiet")

      # Start a detached container mounting the sandbox dir to /sandbox
      @container_id = `docker run -d --rm -v #{@path}:/sandbox #{image_name}`.strip
    end

    def stop_container
      return unless @container_id

      # Stop and remove the container (it's --rm so stopping also removes it)
      system("docker stop #{@container_id}", out: File::NULL, err: File::NULL)
    end
  end
end
