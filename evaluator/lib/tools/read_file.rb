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
        target = secure_path(path, working_dir_path)
        return 'Error: File not found' unless target.exist?

        target.read
      end
    end
  end
end
