# frozen_string_literal: true

require 'rubygems/package'

module Evaluator
  # Verifies that a built gem package includes the files required for release.
  class PackageVerifier
    # Raised when a built gem package is missing required files.
    class Error < StandardError; end

    # Files that must be present for a usable evaluator gem package.
    REQUIRED_FILES = %w[
      README.md
      LICENSE
      bin/evaluate
      docs/architecture.md
      docs/testing-guide.md
      lib/agent_evaluator.rb
      lib/evaluator/config/applier.rb
      lib/evaluator/config/defaults.rb
      lib/evaluator/config/env_overrides.rb
      lib/evaluator/config/facade_readers.rb
      lib/evaluator/config/facade_writers.rb
      lib/evaluator/config/json_loader.rb
      lib/evaluator/config/store.rb
      lib/evaluator/package_verifier.rb
      lib/evaluator/source_path_resolver.rb
      lib/runner.rb
    ].freeze

    # Verifies that a gem package includes required release files.
    #
    # @param package_path [String] path to the built `.gem` file
    # @param required_files [Array<String>] files that must be present in the gemspec payload
    # @return [Hash] result envelope with package verification details
    def self.call(package_path:, required_files: REQUIRED_FILES)
      new(package_path:, required_files:).call
    end

    # Initializes the verifier.
    #
    # @param package_path [String] path to the built `.gem` file
    # @param required_files [Array<String>] files that must be present in the gemspec payload
    # @return [PackageVerifier] a verifier instance
    def initialize(package_path:, required_files: REQUIRED_FILES)
      @package_path = package_path
      @required_files = required_files
    end

    # Verifies that the configured package contains all required files.
    #
    # @return [Hash] result envelope with package verification details
    def call
      files = packaged_files
      missing = @required_files - files
      return failure("Missing packaged files: #{missing.join(', ')}") if missing.any?

      { success: true, response: { missing_files: [], packaged_files: files } }
    rescue StandardError => e
      failure(e.message)
    end

    private

    def packaged_files
      Gem::Package.new(@package_path).spec.files
    end

    def failure(message)
      {
        success: false,
        response: {
          error: { message: message }
        }
      }
    end
  end
end
