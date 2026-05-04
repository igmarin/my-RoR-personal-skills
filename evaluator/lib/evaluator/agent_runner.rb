# frozen_string_literal: true

require_relative 'sandbox'
require_relative '../context_hydrator'
require_relative '../react_agent'

module Evaluator
  # Responsible for executing a specific scenario (baseline or context-hydrated)
  # within an isolated sandbox. Handles the system prompt generation and agent execution.
  class AgentRunner
    SEPARATOR = '================================================='

    # Executes the agent run scenario.
    #
    # @param params [Hash] The configuration parameters for the run.
    # @option params [Symbol] :mode The mode to run in (`:baseline` or `:context`).
    # @option params [Pathname] :full_eval_path The path to the evaluation directory.
    # @option params [String] :task_content The task description.
    # @option params [Hash] :client_params Parameters for the LLM client.
    # @option params [String] :source_path Required if mode is `:context`.
    # @option params [Pathname] :base_path Required if mode is `:context`.
    # @return [Array<String, String>] The agent's final answer and the git diff.
    def self.call(params)
      new(params).call
    end

    # @param params [Hash] The configuration parameters for the run.
    def initialize(params)
      @mode = params.fetch(:mode)
      @full_eval_path = params.fetch(:full_eval_path)
      @task_content = params.fetch(:task_content)
      @client_params = params.fetch(:client_params, {})

      @source_path = params[:source_path]
      @base_path = params[:base_path]
    end

    # Runs the evaluation scenario and captures the results.
    #
    # @return [Array<String, String>] A tuple containing the final answer and the diff.
    def call
      print_header

      Sandbox.run(@full_eval_path) do |sandbox_dir|
        agent_result = ReactAgent.call(
          client_params: @client_params,
          working_dir: sandbox_dir,
          system_prompt: build_system_prompt,
          initial_prompt: @task_content
        )

        response = agent_result[:response]
        final_answer = agent_result[:success] ? response[:content] : "Error: #{response[:error][:message]}"
        [final_answer, Sandbox.capture_diff(sandbox_dir)]
      end
    end

    private

    # Prints a visual separator to the console based on the current mode.
    #
    # @return [void]
    def print_header
      puts SEPARATOR
      if @mode == :baseline
        puts 'Running BASELINE evaluation (without context)...'
      else
        puts 'Running CONTEXT-HYDRATED evaluation...'
      end
      puts SEPARATOR
    end

    # Builds the appropriate system prompt based on the execution mode.
    #
    # @return [String] The system prompt for the agent.
    def build_system_prompt
      if @mode == :baseline
        <<~PROMPT
          You are an expert Ruby on Rails developer.#{' '}
          Your job is to read the task, modify the codebase using the tools provided to meet the requirements, and then explain what you did.
        PROMPT
      else
        hydrator_result = ContextHydrator.call(source_path: @source_path, base_path: @base_path)
        context_xml = hydrator_result[:success] ? hydrator_result[:response][:context] : ''

        <<~PROMPT
          You are an expert Ruby on Rails developer.
          You have access to specific skill files wrapped in <agent_context> tags.
          Use these skills exactly as instructed to solve the user's task.
          Modify the codebase using the tools provided to meet the requirements, and then explain what you did.

          #{context_xml}
        PROMPT
      end
    end
  end
end
