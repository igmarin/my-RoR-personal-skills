# frozen_string_literal: true

require_relative "client"
require_relative "context_hydrator"
require "json"

module Evaluator
  class Runner
    def initialize
      @client = Client.new
      @hydrator = ContextHydrator.new
      @base_path = Pathname.new(File.expand_path("../../", __dir__))
    end

    def evaluate(eval_folder_path, skill_path)
      full_eval_path = @base_path.join(eval_folder_path)
      task_content = File.read(full_eval_path.join("task.md"))
      criteria_content = File.read(full_eval_path.join("criteria.json"))
      
      puts "Running baseline evaluation (without context)..."
      baseline_result = run_baseline(task_content)

      puts "Running context-hydrated evaluation..."
      context_result = run_with_context(task_content, skill_path)

      puts "Running judge evaluation..."
      judge_score = run_judge(task_content, criteria_content, baseline_result, context_result)
      
      {
        baseline: baseline_result,
        with_context: context_result,
        judge_score: judge_score
      }
    end

    private

    def run_baseline(task_content)
      system_prompt = "You are an expert Ruby on Rails developer. Respond to the task directly."
      @client.complete(system_prompt: system_prompt, prompt: task_content)
    end

    def run_with_context(task_content, skill_path)
      context_xml = @hydrator.hydrate(skill_path)
      system_prompt = "You are an expert Ruby on Rails developer. You have access to specific skill files wrapped in <agent_context> tags. Use these skills exactly as instructed to solve the user's task."
      
      prompt = <<~PROMPT
        #{context_xml}

        Task:
        #{task_content}
      PROMPT

      @client.complete(system_prompt: system_prompt, prompt: prompt)
    end

    def run_judge(task_content, criteria_content, baseline_result, context_result)
      system_prompt = "You are an objective judge evaluating AI coding models. Your goal is to score responses based strictly on the provided criteria."
      
      prompt = <<~PROMPT
        You need to evaluate two AI responses against a set of criteria.

        <task>
        #{task_content}
        </task>

        <criteria>
        #{criteria_content}
        </criteria>

        <baseline_response>
        #{baseline_result}
        </baseline_response>

        <context_response>
        #{context_result}
        </context_response>

        Please analyze both responses. Did they fulfill the criteria?
        Provide a final score out of 100 for each, and explain why.
        Output your response as JSON with format:
        {
          "baseline_score": number,
          "context_score": number,
          "reasoning": "..."
        }
      PROMPT

      @client.complete(system_prompt: system_prompt, prompt: prompt)
    end
  end
end
