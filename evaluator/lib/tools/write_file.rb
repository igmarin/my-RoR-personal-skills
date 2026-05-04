# frozen_string_literal: true

require_relative 'base'

# Top-level namespace for the Rails Agent Evaluator.
module Evaluator
  # Contains tool implementations for the evaluator.
  module Tools
    # Handles writing content to a file within the working directory.
    class WriteFile < Base
      # @return [Hash] The tool definition for the LLM API.
      def self.definition
        {
          type: 'function',
          function: {
            name: 'write_file',
            description: 'Write content to a file. Overwrites the file if it exists.',
            parameters: {
              type: 'object',
              properties: {
                path: { type: 'string', description: 'Relative path to the file to write.' },
                content: { type: 'string', description: 'The content to write into the file.' }
              },
              required: %w[path content],
              additionalProperties: false
            }
          }
        }
      end

      # Writes content to a file. Creates missing parent directories.
      #
      # @param path [String] The relative path to the file.
      # @param content [String] The content to write.
      # @param working_dir_path [Pathname] The working directory to resolve the path against.
      # @return [String] A success message.
      def self.call(path, content, working_dir_path)
        validate_write_path!(path)

        target = secure_path(path, working_dir_path)
        target.dirname.mkpath
        target.write(content)
        "Successfully wrote to #{path}"
      end

      class << self
        private

        # Validates the path against strict security rules to prevent traversal.
        # Following recommendations to disallow directory separators and multiple dots.
        #
        # @param path [String] The relative path to validate.
        # @raise [ArgumentError] if the path is invalid, empty, or attempts traversal.
        # @return [void]
        def validate_write_path!(path)
          raise ArgumentError, 'Path must be a string' unless path.is_a?(String)

          normalized = path.strip
          raise ArgumentError, 'Path cannot be empty' if normalized.empty?

          # Allow forward slashes for nested directories, but reject '..'
          raise ArgumentError, "Path traversal attempt: #{path}" if normalized.include?('..')

          raise ArgumentError, "Backslashes are not allowed in path: #{path}" if normalized.include?('\\')

          raise ArgumentError, "More than one dot is not allowed in path: #{path}" if normalized.count('.') > 1

          return if normalized.match?(%r{\A[a-zA-Z0-9._\-/]+\z})

          raise ArgumentError, "Invalid characters in path: #{path}"
        end
      end
    end
  end
end
