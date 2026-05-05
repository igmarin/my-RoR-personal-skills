# frozen_string_literal: true

require_relative 'tools/registry'
require_relative 'tools/dispatcher'

module Evaluator
  # Provides the definitions and execution logic for tools available to the ReAct agent.
  # Currently supports reading files, writing files, and running shell commands.
  module Tools
    # Returns an array of tool definitions in the format expected by the LLM API.
    #
    # @return [Array<Hash>] The list of available tools with their names, descriptions, and schemas.
    def self.definitions
      Registry.definitions
    end

    # Executes a specified tool with the given arguments within a working directory.
    #
    # @param name [String] The name of the tool to execute (e.g., 'read_file').
    # @param arguments [String] A JSON string containing the arguments for the tool.
    # @param working_dir [String] The base directory in which the tool should operate.
    # @param container_id [String, nil] The Docker container ID for isolated execution.
    # @return [String] The result of the tool execution, or an error message.
    def self.execute(name, arguments, working_dir, container_id = nil)
      Dispatcher.call(name, arguments, working_dir, container_id)
    end
  end
end
