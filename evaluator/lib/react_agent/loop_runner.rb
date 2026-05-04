# frozen_string_literal: true

require_relative 'step'

module Evaluator
  class ReactAgent
    # Executes the ReAct loop iterations until completion or max iterations.
    class LoopRunner
      # Executes the loop.
      #
      # @param initial_prompt [String] The user task the agent must complete.
      # @param max_iterations [Integer] The maximum allowed steps before aborting.
      # @param config [Hash] The configuration for the Step execution.
      # @return [Hash] A result hash indicating success or failure.
      def self.call(initial_prompt, max_iterations, config)
        messages = [{ role: 'user', content: initial_prompt }]
        iterations = 0

        while iterations < max_iterations
          iterations += 1
          puts "  -> Iteration #{iterations}..."

          step_result = Step.call(messages, config)
          return step_result[:result] unless step_result[:continue]

          messages = step_result[:messages]
        end

        { success: false, response: { error: { message: ReactAgent::MAX_ITERATIONS_REACHED } } }
      rescue StandardError => e
        error_msg = e.message
        Rails.logger.error("ReactAgent Error: #{error_msg}") if defined?(Rails)
        { success: false, response: { error: { message: error_msg } } }
      end
    end
  end
end
