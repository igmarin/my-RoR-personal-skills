# frozen_string_literal: true

require 'json'
require 'date'
require 'fileutils'

# Top-level namespace for the Rails Agent Evaluator.
module Evaluator
  # Records evaluation results into a historical benchmarks file.
  class HistoryRecorder
    # The default file where historical benchmarks are stored.
    HISTORY_FILE = File.join(__dir__, '../../benchmarks.json')

    # Records evaluation results into a historical benchmarks file.
    #
    # @param results [Hash] The results from a Runner.call.
    # @param source_path [String] The resolved source path used for the evaluation.
    # @param model [String] The model name used for the evaluation.
    # @return [void]
    # @raise [SystemCallError] when the history file cannot be written.
    def self.record(results, source_path:, model:)
      return unless results[:success]

      # Choose writable path first
      history_file = determine_history_file
      return unless history_file

      history = load_history(history_file)
      entry = {
        timestamp: Time.now.iso8601,
        source_path: source_path,
        model: model,
        summary: summarize(results[:tasks])
      }

      history << entry

      File.write(history_file, JSON.pretty_generate(history))
      puts "History recorded to #{history_file}"
    rescue StandardError => e
      log_error(e)
      false
    end

    # Determines the best writable path for benchmarks.json
    #
    # @return [String, nil] Path to writable file, or nil if none found.
    def self.determine_history_file
      # 1. Check ENV variable first
      env_history_file = ENV.fetch('EVALUATOR_HISTORY_FILE', nil)
      return env_history_file if env_history_file && !env_history_file.to_s.strip.empty?

      # 2. Try current working directory (for backward compat)
      cwd_path = File.join(Dir.pwd, 'benchmarks.json')
      return cwd_path if writable?(cwd_path)

      # 3. Try user's local share directory
      home_dir = Dir.home
      local_path = File.join(home_dir, '.local', 'share', 'agent_evaluator', 'benchmarks.json')
      return local_path if prepare_and_writable?(local_path)

      # 4. Try XDG data home
      xdg_data_home = ENV.fetch('XDG_DATA_HOME', File.join(home_dir, '.local', 'share'))
      xdg_path = File.join(xdg_data_home, 'agent_evaluator', 'benchmarks.json')
      return xdg_path if prepare_and_writable?(xdg_path)

      warn('Warning: Could not find writable location for benchmarks.json')
      nil
    end

    # Checks if a path is writable, creating parent dirs if needed.
    #
    # @param path [String] The path to check.
    # @return [Boolean]
    def self.prepare_and_writable?(path)
      dir_name = File.dirname(path)
      FileUtils.mkpath(dir_name)
      File.writable?(dir_name)
    rescue StandardError => e
      log_error(e)
      false
    end

    # Checks if a file location is writable.
    #
    # @param path [String] The path to check.
    # @return [Boolean]
    def self.writable?(path)
      File.writable?(File.dirname(path))
    rescue StandardError => e
      log_error(e)
      false
    end

    # Loads existing history from the benchmarks file.
    #
    # @param path [String] The path to the history file.
    # @return [Array<Hash>] The list of historical evaluation entries.
    def self.load_history(path = HISTORY_FILE)
      return [] unless File.exist?(path)

      JSON.parse(File.read(path), symbolize_names: true)
    rescue StandardError => e
      log_error(e) unless e.is_a?(JSON::ParserError)
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

    # Logs errors with backtrace
    #
    # @param exception [StandardError]
    def self.log_error(exception)
      msg = "#{exception.message}\n#{exception.backtrace.first(5).join("\n")}"
      if defined?(Rails)
        Rails.logger.error(msg)
      else
        warn("HistoryRecorder Error: #{msg}")
      end
    end
    private_class_method :log_error

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
