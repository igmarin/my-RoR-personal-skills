# frozen_string_literal: true

require_relative 'read_file'
require_relative 'write_file'
require_relative 'run_command'

module Evaluator
  module Tools
    # Registry for all available tools, providing their definitions to the LLM.
    class Registry
      # Returns an array of tool definitions in the format expected by the LLM API.
      #
      # @return [Array<Hash>] The list of available tools with their names, descriptions, and schemas.
      def self.definitions
        [
          ReadFile.definition,
          WriteFile.definition,
          RunCommand.definition
        ]
      end
    end
  end
end
