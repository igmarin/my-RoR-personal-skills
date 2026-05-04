# frozen_string_literal: true

require_relative '../tools'

module Evaluator
  class ReactAgent
    # Service object responsible for executing a list of tool calls and returning the results
    # formatted as messages to be appended to the conversation history.
    class ToolExecutor
      # Executes the provided tool calls.
      #
      # @param tool_calls [Array<Hash>] The tool calls requested by the LLM.
      # @param working_dir [String] The directory where tools should operate.
      # @return [Array<Hash>] An array of message hashes containing tool results.
      def self.call(tool_calls, working_dir)
        tool_calls.map do |tool_call|
          function_name = tool_call.dig('function', 'name')
          arguments = tool_call.dig('function', 'arguments')

          puts "=== Calling Tool: #{function_name} ==="
          puts "Args: #{arguments}"

          result = Tools.execute(function_name, arguments, working_dir)

          {
            role: 'tool',
            tool_call_id: tool_call['id'],
            content: result
          }
        end
      end
    end
  end
end
