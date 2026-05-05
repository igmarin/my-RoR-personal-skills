# frozen_string_literal: true
require 'json'
require 'date'
require_relative 'history_recorder/persistence_service'
require_relative 'history_recorder/summary_service'

# Top-level namespace for the Rails Agent Evaluator.
module Evaluator
  # Records evaluation results into a historical benchmarks file.
  # Now delegates to specialized services following Single Responsibility Principle.
  class HistoryRecorder
    # The default file where historical benchmarks are stored.
    HISTORY_FILE = PersistenceService::HISTORY_FILE

    # Records evaluation results into a historical benchmarks file.
    # Delegates to PersistenceService.
    def self.record(results, source_path:, model:)
      PersistenceService.record(results, source_path: source_path, model: model)
    end

    # Loads existing history from the benchmarks file.
    # Delegates to PersistenceService.
    def self.load_history(path = HISTORY_FILE)
      PersistenceService.load_history(path)
    end

    # Summarizes the results of multiple tasks.
    # Delegates to SummaryService.
    def self.summarize(tasks)
      SummaryService.summarize(tasks)
    end

    # Logs errors with backtrace.
    # Kept here for backward compatibility.
    def self.log_error(exception)
      PersistenceService.log_error(exception)
    end
  end
end
