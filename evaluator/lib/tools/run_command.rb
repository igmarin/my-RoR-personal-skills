# frozen_string_literal: true

require 'open3'
require 'timeout'
require 'shellwords'
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

      # Executes a shell command within the working directory (host or container).
      #
      # Tokenizes the command string before execution so that arguments are passed
      # directly to the OS without shell interpretation, preventing shell injection.
      #
      # @param command [String] The command to run (e.g. "rspec spec/models").
      # @param working_dir_path [Pathname] The host directory (ignored if container_id present).
      # @param container_id [String, nil] The Docker container ID for isolated execution.
      # @return [String] A formatted string containing the exit status, STDOUT, and STDERR.
      # @raise [Timeout::Error] Internally rescued; returns a timeout message string.
      def self.call(command, working_dir_path, container_id = nil)
        argv = command.shellsplit
        base_cmd = argv.first
        allowed = Evaluator::Config.allowed_commands
        return "Error: Command '#{base_cmd}' is not permitted. Allowed commands are: #{allowed.join(', ')}." if allowed && !allowed.include?(base_cmd)

        max_time = Evaluator::Config.max_execution_time
        Timeout.timeout(max_time) do
          stdout_str, stderr_str, status = if container_id
                                             # Execute inside the Docker container
                                             # Environment is naturally scrubbed as docker exec doesn't inherit host ENV
                                             docker_cmd = ['docker', 'exec', '-w', '/sandbox', container_id] + argv
                                             Open3.capture3(*docker_cmd)
                                           else
                                             # Fallback to host execution
                                             Open3.capture3(*argv, chdir: working_dir_path.to_s)
                                           end
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
