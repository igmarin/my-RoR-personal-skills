# frozen_string_literal: true

require 'open3'
require 'timeout'
require_relative '../config'

module Evaluator
  module Tools
    # Handles executing a shell command within the working directory.
    class RunCommand
      # @return [Hash] The tool definition for the LLM API.
      def self.definition
        {
          type: 'function',
          function: {
            name: 'run_command',
            description: 'Execute a shell command (e.g., rspec).',
            parameters: {
              type: 'object',
              properties: {
                command: { type: 'string', description: 'The shell command to run.' }
              },
              required: ['command'],
              additionalProperties: false
            }
          }
        }
      end

      # Executes a shell command within the working directory.
      #
      # @param command [String] The command to run.
      # @param working_dir_path [Pathname] The directory in which to run the command.
      # @return [String] A formatted string containing the exit status, STDOUT, and STDERR.
      def self.call(command, working_dir_path)
        base_cmd = command.split.first
        allowed = Evaluator::Config.allowed_commands
        return "Error: Command '#{base_cmd}' is not permitted. Allowed commands are: #{allowed.join(', ')}." if allowed && !allowed.include?(base_cmd)

        begin
          max_time = Evaluator::Config.max_execution_time
          Timeout.timeout(max_time) do
            stdout_str, stderr_str, status = Open3.capture3(command, chdir: working_dir_path.to_s)
            <<~RESULT
              Exit Status: #{status.exitstatus}
              STDOUT:
              #{stdout_str}
              STDERR:
              #{stderr_str}
            RESULT
          end
        rescue Timeout::Error
          "Error: Command execution timed out after #{max_time} seconds."
        end
      end
    end
  end
end
