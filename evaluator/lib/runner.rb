# frozen_string_literal: true

require 'pathname'
require 'parallel'
require_relative 'client'
require_relative 'context_hydrator'
require_relative 'react_agent'
require_relative 'evaluator/sandbox'
require_relative 'evaluator/judge'
require_relative 'evaluator/agent_runner'
require_relative 'evaluator/source_path_resolver'

module Evaluator
  # Orchestrates the entire evaluation process.
  # Compares how an AI coding agent performs with and without contextual skills.
  class Runner
    SEPARATOR = '================================================='

    # Initiates a full evaluation run.
    #
    # @param params [Hash] The configuration for the evaluation.
    # @option params [String] :eval_folder_path The path to the evaluation directory containing task and criteria.
    # @option params [String] :skill_path Optional override for the source directory being tested.
    # @option params [String, Pathname] :base_path (optional) The base path for relative file resolution.
    # @option params [Hash] :client_params (optional) Parameters to pass to the LLM client.
    # @return [Hash] A result hash with :success and :response payload containing the judge scores and diffs.
    # @raise [ArgumentError] If the eval path does not match a supported source-path convention.
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
      full_path = @base_path.join(@eval_folder_path)

      return { success: false, response: { error: { message: "Evaluation path #{full_path} does not exist" } } } unless full_path.exist?

      task_dirs = self.class.discover_task_dirs(full_path)
      if task_dirs.empty?
        return { success: false,
                 response: { error: { message: "No task.md found in #{full_path} or its subdirectories" } } }
      end

      puts "Found #{task_dirs.size} tasks. Running evaluations in parallel (4 threads)..."
      results = Parallel.map(task_dirs, in_threads: 4) do |task_dir|
        evaluate_task(task_dir)
      end

      {
        success: true,
        source_path: @skill_path || 'multiple (batch run)',
        tasks: results
      }
    rescue StandardError => e
      { success: false, response: { error: { message: e.message } } }
    end

    # Prints the judge evaluation header.
    #
    # @param relative_path [Pathname] The relative path to the task.
    # @return [void]
    # :reek:DuplicateMethodCall { enabled: false }
    def print_judge_header(relative_path)
      puts SEPARATOR
      puts "Running JUDGE evaluation for #{relative_path}..."
      puts SEPARATOR
    end

    # Evaluates a single task within the given directory.
    #
    # @param full_eval_path [Pathname] The path to the evaluation directory.
    # @return [Hash] The result of the task evaluation.
    # @raise [StandardError] If reading files or invoking AgentRunner.call or Judge.call fails and the error bubbles up.
    def evaluate_task(full_eval_path)
      task_content = File.read(full_eval_path.join('task.md'))
      criteria_content = File.read(full_eval_path.join('criteria.json'))
      relative_path = full_eval_path.relative_path_from(@base_path)

      source_path = SourcePathResolver.call(
        eval_folder_path: relative_path.to_s,
        skill_path: @skill_path
      )

      baseline_result, baseline_code_diff = AgentRunner.call(
        mode: :baseline,
        full_eval_path: full_eval_path,
        task_content: task_content,
        client_params: @client_params
      )

      if source_path
        context_result, context_code_diff = AgentRunner.call(
          mode: :context,
          full_eval_path: full_eval_path,
          task_content: task_content,
          client_params: @client_params,
          source_path: source_path,
          base_path: @base_path
        )
      else
        puts "Warning: No source path inferred for #{relative_path}. Skipping context run."
        context_result = 'Skipped: No source path inferred'
        context_code_diff = ''
      end

      print_judge_header(relative_path)
      judge_score = Judge.call(task_content, criteria_content, baseline_code_diff, context_code_diff, @client_params)

      {
        path: relative_path.to_s,
        baseline: baseline_result,
        baseline_diff: baseline_code_diff,
        with_context: context_result,
        context_diff: context_code_diff,
        judge_score: judge_score
      }
    end

    # Finds all directories containing a task.md file starting from the root_path.
    #
    # @param root_path [Pathname] The root directory to search.
    # @return [Array<Pathname>] A list of task directory paths.
    def self.discover_task_dirs(root_path)
      if File.exist?(root_path.join('task.md'))
        [root_path]
      else
        Dir.glob(root_path.join('**/task.md')).map { |f| Pathname.new(f).parent }.uniq.sort
      end
    end
  end
end
