# frozen_string_literal: true

require_relative '../client'

module Evaluator
  # Responsible for evaluating AI-generated code modifications.
  # Compares baseline and context-hydrated diffs against given criteria.
  class Judge
    # Evaluates two code diffs against a specific task and criteria.
    #
    # @param task_content [String] The description of the task to be completed.
    # @param criteria_content [String] The criteria used for scoring the solutions.
    # @param baseline_diff [String] The diff generated without context.
    # @param context_diff [String] The diff generated with context.
    # @param client_params [Hash] Optional parameters to pass to the client.
    # @return [String] A JSON string containing the scores and reasoning.
    def self.call(task_content, criteria_content, baseline_diff, context_diff, client_params = {})
      new(task_content, criteria_content, baseline_diff, context_diff, client_params).call
    end

    # @param task_content [String] The description of the task to be completed.
    # @param criteria_content [String] The criteria used for scoring the solutions.
    # @param baseline_diff [String] The diff generated without context.
    # @param context_diff [String] The diff generated with context.
    # @param client_params [Hash] Optional parameters to pass to the client.
    def initialize(task_content, criteria_content, baseline_diff, context_diff, client_params)
      @task_content = task_content
      @criteria_content = criteria_content
      @baseline_diff = baseline_diff
      @context_diff = context_diff
      @client_params = client_params
    end

    # Executes the evaluation process via the LLM client.
    #
    # @return [String] A JSON string representing the judge's score and reasoning.
    def call
      system_prompt = 'You are an objective judge evaluating AI coding models. Your goal is to score responses based strictly on the provided criteria.'

      prompt = <<~PROMPT
        You need to evaluate two AI codebase modifications against a set of criteria.

        <task>
        #{@task_content}
        </task>

        <criteria>
        #{@criteria_content}
        </criteria>

        <baseline_code_diff>
        #{@baseline_diff}
        </baseline_code_diff>

        <context_code_diff>
        #{@context_diff}
        </context_code_diff>

        Please analyze both code diffs. Did they fulfill the criteria?
        Did the context_code_diff follow any specific instructions better?
        Provide a final score out of 100 for each, and explain why.
        Output your response as JSON with format:
        {
          "baseline_score": number,
          "context_score": number,
          "reasoning": "..."
        }
      PROMPT

      judge_result = Client.call(
        @client_params.merge(
          system_prompt: system_prompt,
          messages: [{ role: 'user', content: prompt }]
        )
      )

      response = judge_result[:response]
      judge_result[:success] ? response[:message]['content'] : "Error running judge: #{response[:error][:message]}"
    end
  end
end
