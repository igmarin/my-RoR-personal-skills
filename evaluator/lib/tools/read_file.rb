# frozen_string_literal: true

require_relative 'base'

module Evaluator
  module Tools
    # Handles reading the contents of a file within the working directory.
    class ReadFile < Base
      # @return [Hash] The tool definition for the LLM API.
      def self.definition
        {
          type: 'function',
          function: {
            name: 'read_file',
            description: 'Read the contents of a file.',
            parameters: {
              type: 'object',
              properties: {
                path: { type: 'string', description: 'Relative path to the file to read.' }
              },
              required: ['path'],
              additionalProperties: false
            }
          }
        }
      end

      # Reads the contents of a file.
      #
      # @param path [String] The relative path to the file.
      # @param working_dir_path [Pathname] The working directory to resolve the path against.
      # @return [String] The file contents, or an error message if not found.
      def self.call(path, working_dir_path)
        validation_error = validate_read_file_path(path)
        return validation_error if validation_error

        target = secure_path(path, working_dir_path)
        return 'Error: File not found' unless target.exist? && target.file?
        return 'Error: File is not readable' unless target.readable?

        target.read
      rescue ArgumentError
        raise
      rescue StandardError => e
        "Error reading file: #{e.message}"
      end

      class << self
        private

        def validate_read_file_path(path)
          return 'Error: Invalid path. Path must be a string.' unless path.is_a?(String)

          normalized = path.strip
          return 'Error: Invalid path. Path must not be empty.' if normalized.empty?
          raise ArgumentError, "Path traversal attempt: #{path}" if normalized.include?('/') || normalized.include?('\\')
          return 'Error: Invalid path. More than one dot is not allowed.' if normalized.count('.') > 1
          return 'Error: Invalid path. Allowed characters are letters, numbers, dot, underscore, and hyphen.' unless normalized.match?(/\A[a-zA-Z0-9._-]+\z/)

          nil
        end
      end
    end
  end
end
