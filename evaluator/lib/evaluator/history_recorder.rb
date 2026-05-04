# frozen_string_literal: true

require 'json'
require 'date'

# Top-level namespace for the Rails Agent Evaluator.
module Evaluator
  # Records evaluation results into a historical benchmarks file.
  class HistoryRecorder
    # The file where historical benchmarks are stored.
    HISTORY_FILE = 'benchmarks.json'

    # Records evaluation results into a historical benchmarks file.
    #
    # @param results [Hash] The results from a Runner.call.
    # @param source_path [String] The resolved source path used for the evaluation.
    # @param model [String] The model name used for the evaluation.
    # @return [void]
    # @raise [SystemCallError] when the history file cannot be written.
    def self.record(results, source_path:, model:)
      return unless results[:success]

      history = load_history
      entry = {
        timestamp: Time.now.iso8601,
        source_path: source_path,
        model: model,
        summary: summarize(results[:tasks])
      }

      history << entry
      File.write(HISTORY_FILE, JSON.pretty_generate(history))
      puts "History recorded to #{HISTORY_FILE}"
    end

    # Loads existing history from the benchmarks file.
    #
    # @return [Array<Hash>] The list of historical evaluation entries.
    def self.load_history
      return [] unless File.exist?(HISTORY_FILE)

      JSON.parse(File.read(HISTORY_FILE), symbolize_names: true)
    rescue JSON::ParserError
      []
    end

    # Summarizes the results of multiple tasks.
    #
    # @param tasks [Array<Hash>] The list of task results.
    # @return [Hash] A summary of scores including averages and improvement.
    def self.summarize(tasks)
      return {} if tasks.nil? || tasks.empty?

      scores = tasks.map { |task| normalize_score(task[:judge_score]) }
      calculate_summary(scores)
    end

    class << self
      private

      # Normalizes the raw judge score into a standardized Hash.
      #
      # @param raw_score [String, Hash, nil] The raw score from the judge.
      # @return [Hash] The normalized score with :baseline_score and :context_score.
      def normalize_score(raw_score)
        return {} if raw_score.nil?
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
      def calculate_summary(scores)
        count = scores.size
        total_baseline = scores.sum { |s| (s[:baseline_score] || 0).to_f }
        total_context = scores.sum { |s| (s[:context_score] || 0).to_f }

        {
          task_count: count,
          average_baseline: (total_baseline / count).round(2),
          average_context: (total_context / count).round(2),
          improvement: ((total_context - total_baseline) / count).round(2)
        }
      end
    end
  end
end
