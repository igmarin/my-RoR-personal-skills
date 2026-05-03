# frozen_string_literal: true

require 'pathname'
require_relative 'client'
require_relative 'context_hydrator'
require_relative 'react_agent'
require_relative 'evaluator/sandbox'
require_relative 'evaluator/judge'
require_relative 'evaluator/agent_runner'

module Evaluator
  # Orchestrates the entire evaluation process.
  # Compares how an AI coding agent performs with and without contextual skills.
  class Runner
    # Initiates a full evaluation run.
    #
    # @param params [Hash] The configuration for the evaluation.
    # @option params [String] :eval_folder_path The path to the evaluation directory containing task and criteria.
    # @option params [String] :skill_path The path to the skill being tested.
    # @option params [String, Pathname] :base_path (optional) The base path for relative file resolution.
    # @option params [Hash] :client_params (optional) Parameters to pass to the LLM client.
    # @return [Hash] A result hash with :success and :response payload containing the judge scores and diffs.
    def self.call(params)
      new(params).call
    end

    # @param params [Hash] The configuration for the evaluation.
    def initialize(params)
      @eval_folder_path = params[:eval_folder_path]
      @skill_path = params[:skill_path]
      @base_path = params[:base_path] || Pathname.new(File.expand_path('../../', __dir__))
      @client_params = params[:client_params] || {}
    end

    # Executes the baseline and context-hydrated evaluations, then scores them.
    #
    # @return [Hash] The final evaluation result.
    def call
      full_eval_path = @base_path.join(@eval_folder_path)

      return { success: false, response: { error: { message: "Evaluation path #{full_eval_path} does not exist" } } } unless full_eval_path.exist?

      task_content = File.read(full_eval_path.join('task.md'))
      criteria_content = File.read(full_eval_path.join('criteria.json'))

      baseline_result, baseline_code_diff = AgentRunner.call(
        mode: :baseline,
        full_eval_path: full_eval_path,
        task_content: task_content,
        client_params: @client_params
      )

      context_result, context_code_diff = AgentRunner.call(
        mode: :context,
        full_eval_path: full_eval_path,
        task_content: task_content,
        client_params: @client_params,
        skill_path: @skill_path,
        base_path: @base_path
      )

      puts '================================================='
      puts 'Running JUDGE evaluation...'
      puts '================================================='
      judge_score = Judge.call(task_content, criteria_content, baseline_code_diff, context_code_diff, @client_params)

      {
        success: true,
        response: {
          baseline: baseline_result,
          baseline_diff: baseline_code_diff,
          with_context: context_result,
          context_diff: context_code_diff,
          judge_score: judge_score
        }
      }
    rescue StandardError => e
      Rails.logger.error("Runner Error: #{e.message}") if defined?(Rails)
      { success: false, response: { error: { message: e.message } } }
    end
  end
end
