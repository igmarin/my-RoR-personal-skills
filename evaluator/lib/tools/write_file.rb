# frozen_string_literal: true

require_relative 'base'

module Evaluator
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
        target = secure_path(path, working_dir_path)
        target.dirname.mkpath
        target.write(content)
        "Successfully wrote to #{path}"
      end
    end
  end
end
