# frozen_string_literal: true

require 'json'
require 'fileutils'

module Evaluator
  module Services
    # Service object for persisting evaluation results to JSON files.
    # Handles directory creation, file writing, and provides standardized error handling.
    class OutputPersistenceService
      WRITE_ERROR = 'Failed to write output file'

      # Persists evaluation results to a JSON file with proper formatting.
      #
      # @param result [Hash] Evaluation result hash containing all evaluation data
      # @param output_path [String, nil] Path to save the JSON report. If nil or empty, no action is taken
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: { message: String } } on success
      #   - { success: true, response: {} } when no output path is provided
      #   - { success: false, response: { error: { message: String } } } on failure
      # @example Save to file
      #   result = OutputPersistenceService.call(evaluation_result, output_path: 'output.json')
      #   # => { success: true, response: { message: 'Report saved to output.json' } }
      # @example No output path
      #   result = OutputPersistenceService.call(evaluation_result, output_path: nil)
      #   # => { success: true, response: {} }
      def self.call(result, output_path:)
        new(result, output_path: output_path).call
      end

      # Initializes a new persistence service instance.
      #
      # @param result [Hash] Evaluation result hash containing all evaluation data
      # @param output_path [String, nil] Path to save the JSON report
      def initialize(result, output_path:)
        @result = result
        @output_path = output_path
      end

      # Persists the evaluation result to the specified output path.
      #
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: { message: String } } on success
      #   - { success: true, response: {} } when no output path is provided
      #   - { success: false, response: { error: { message: String } } } on failure
      # @raise [SystemCallError] when file system operations fail (handled internally)
      def call
        return { success: true, response: {} } if @output_path.to_s.empty?

        ensure_directory_exists
        write_json_file

        { success: true, response: { message: "Report saved to #{@output_path}" } }
      rescue SystemCallError => e
        { success: false, response: { error: { message: "#{WRITE_ERROR}: #{e.message}" } } }
      end

      private

      # Ensures the parent directory for the output file exists.
      # Creates the directory structure if it doesn't exist.
      def ensure_directory_exists
        directory = File.dirname(@output_path)
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
      end

      # Writes the evaluation result as a formatted JSON file.
      #
      # @raise [SystemCallError] when file write operation fails
      def write_json_file
        File.write(@output_path, JSON.pretty_generate(@result))
      end
    end
  end
end
