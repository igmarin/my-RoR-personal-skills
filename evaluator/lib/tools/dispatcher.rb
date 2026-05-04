# frozen_string_literal: true

require 'pathname'
require_relative 'read_file'
require_relative 'write_file'
require_relative 'run_command'
require_relative 'argument_parser'

module Evaluator
  module Tools
    # Dispatches tool execution based on the tool name, coordinating parsing and invocation.
    class Dispatcher
      # Executes a specified tool with the given arguments within a working directory.
      #
      # @param name [String] The name of the tool to execute (e.g., 'read_file').
      # @param arguments [String] A JSON string containing the arguments for the tool.
      # @param working_dir [String] The base directory in which the tool should operate.
      # @return [String] The result of the tool execution, or an error message.
      def self.call(name, arguments, working_dir)
        args = ArgumentParser.call(arguments)
        return args if args.is_a?(String) # Returns the error message if parsing failed

        working_dir_path = Pathname.new(working_dir).expand_path

        execute_tool(name, args, working_dir_path)
      rescue StandardError => e
        "Error executing tool: #{e.message}"
      end

      class << self
        private

        def execute_tool(name, args, working_dir_path)
          path = args['path']
          case name
          when 'read_file'
            ReadFile.call(path, working_dir_path)
          when 'write_file'
            WriteFile.call(path, args['content'], working_dir_path)
          when 'run_command'
            RunCommand.call(args['command'], working_dir_path)
          else
            "Error: Unknown tool '#{name}'"
          end
        end
      end
    end
  end
end
