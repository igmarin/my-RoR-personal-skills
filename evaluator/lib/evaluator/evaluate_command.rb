# frozen_string_literal: true

require_relative '../runner'
require_relative 'history_recorder'
require_relative 'services/option_parser_service'
require_relative 'services/result_printer_service'
require_relative 'services/output_persistence_service'

module Evaluator
  # Implements the `bin/evaluate` CLI command.
  # Orchestrates option parsing, evaluation execution, result printing, and output persistence.
  class EvaluateCommand
    # Parses arguments, runs the evaluator, prints the report, and records history.
    #
    # @param argv [Array<String>] Raw CLI arguments.
    # @param stdout [#puts, #write] Output stream for user-visible messages.
    # @return [Integer] Shell-compatible exit code.
    # @raise [OptionParser::ParseError] when invalid CLI flags are provided.
    # @raise [SystemCallError] if writing output fails.
    def self.call(argv, stdout: $stdout)
      new(argv, stdout: stdout).call
    end

    # @param argv [Array<String>] Raw CLI arguments.
    # @param stdout [#puts, #write] Output stream for user-visible messages.
    def initialize(argv, stdout:)
      @argv = argv
      @stdout = stdout
    end

    # Executes the command by orchestrating service objects.
    #
    # @return [Integer] Shell-compatible exit code.
    # @raise [OptionParser::ParseError] when invalid CLI flags are provided.
    # @raise [SystemCallError] when the optional JSON output file cannot be written.
    def call
      # Parse CLI options
      options_result = Services::OptionParserService.call(@argv)
      return options_result[:success] ? 0 : 1 unless options_result[:success]

      options = options_result[:response]

      # Validate required eval option
      eval_path = options[:eval]
      if eval_path.nil?
        @stdout.puts 'Error: The --eval option is required.'
        @stdout.puts 'Example: bin/evaluate -e evals/skills/infrastructure/rails-api-versioning/api-versioning-with-controller-inheritan'
        return 1
      end

      # Run the evaluation
      result = Evaluator::Runner.call(
        eval_folder_path: File.expand_path(eval_path),
        skill_path: options[:skill] ? File.expand_path(options[:skill]) : nil
      )

      # Print results using the result printer service
      Services::ResultPrinterService.call(result, stdout: @stdout)

      # Return early if evaluation failed
      return 1 unless result[:success]

      # Persist output if requested
      Services::OutputPersistenceService.call(result, output_path: options[:output])

      # Record history
      Evaluator::HistoryRecorder.record(
        result,
        source_path: result[:source_path],
        model: Evaluator::Config.model
      )

      0
    end
  end
end
