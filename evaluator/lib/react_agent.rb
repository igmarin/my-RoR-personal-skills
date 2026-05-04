# frozen_string_literal: true

require_relative 'react_agent/step'
require_relative 'react_agent/loop_runner'

module Evaluator
  # An agent that follows the ReAct (Reasoning and Acting) loop pattern.
  # It executes a given task by repeatedly thinking, invoking tools, and observing the results
  # until it finishes the task or reaches the maximum number of iterations.
  class ReactAgent
    MAX_ITERATIONS_REACHED = 'Reached max iterations without finishing.'

    # Starts the ReAct loop for a specific task.
    #
    # @param params [Hash] The configuration for the agent.
    # @option params [String] :system_prompt The instructions establishing the agent's persona and rules.
    # @option params [String] :initial_prompt The user task the agent must complete.
    # @option params [Integer] :max_iterations (10) The maximum allowed steps before aborting.
    # @option params [String] :working_dir (Dir.pwd) The directory where tools should operate.
    # @option params [Hash] :client_params ({}) Configuration passed to the Client (e.g., model).
    # @return [Hash] A result hash with :success, and :response payload containing the final answer.
    def self.call(params)
      new(params).call
    end

    # @param params [Hash] The configuration for the agent.
    def initialize(params)
      @system_prompt = params[:system_prompt]
      @initial_prompt = params[:initial_prompt]
      @max_iterations = params[:max_iterations] || 10
      @working_dir = params[:working_dir] || Dir.pwd
      @client_params = params[:client_params] || {}
    end

    # Executes the ReAct loop.
    #
    # @return [Hash] The standardized result hash indicating success or failure.
    def call
      config = build_step_config
      LoopRunner.call(@initial_prompt, @max_iterations, config)
    end

    private

    def build_step_config
      {
        system_prompt: @system_prompt,
        client_params: @client_params,
        working_dir: @working_dir
      }
    end
  end
end
