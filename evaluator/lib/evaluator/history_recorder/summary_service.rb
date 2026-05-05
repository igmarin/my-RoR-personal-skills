# frozen_string_literal: true

# frozen_string_literal: true

require 'json'

module Evaluator
  class HistoryRecorder
    # Service object for summarizing evaluation results.
    # Handles score normalization and statistical calculations.
    # Follows Single Responsibility Principle by isolating summary concerns.
    class SummaryService
      # Summarizes the results of multiple tasks.
      #
      # @param tasks [Array<Hash>] The list of task results.
      # @return [Hash] A summary of scores including averages and improvement.
      def self.summarize(tasks)
        return {} if Array(tasks).empty?

        scores = tasks.map { |task| normalize_score(task[:judge_score]) }
        calculate_summary(scores)
      end

      # Normalizes the raw judge score into a standardized Hash.
      #
      # @param raw_score [String, Hash, nil] The raw score from the judge.
      # @return [Hash] The normalized score with :baseline_score and :context_score.
      # @raise [JSON::ParserError] raised when the judge_score string contains invalid JSON (rescued internally).
      def self.normalize_score(raw_score)
        return {} unless raw_score
        return raw_score if raw_score.is_a?(Hash)

        begin
          JSON.parse(raw_score, symbolize_names: true)
        rescue JSON::ParserError
          {}
        end
      end

      # Calculates statistical summary from a list of normalized scores.
      #
      # @param scores [Array<Hash>] List of normalized scores.
      # @return [Hash] Summary statistics.
      def self.calculate_summary(scores)
        count = scores.size
        baseline_total = 0.0
        context_total = 0.0

        scores.each do |score|
          baseline_total += (score[:baseline_score] || 0).to_f
          context_total += (score[:context_score] || 0).to_f
        end

        {
          task_count: count,
          average_baseline: (baseline_total / count).round(2),
          average_context: (context_total / count).round(2),
          improvement: ((context_total - baseline_total) / count).round(2)
        }
      end
    end
  end
end
