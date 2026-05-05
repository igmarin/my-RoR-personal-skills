# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative '../runner'
require_relative 'history_recorder'

module Evaluator
  # Implements the `bin/evaluate` CLI command.
  class EvaluateCommand
    RESULTS_BANNER = "\n=========================================\n              " \
                     "RESULTS                    \n" \
                     "=========================================\n"

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
    # @return [void]
    # @raise [OptionParser::ParseError] when invalid CLI flags are provided during execution.
    def initialize(argv, stdout:)
      @argv = argv
      @stdout = stdout
      @options = {}
    end

    # Executes the command.
    #
    # @return [Integer] Shell-compatible exit code.
    # @raise [OptionParser::ParseError] when invalid CLI flags are provided.
    # @raise [SystemCallError] when the optional JSON output file cannot be written.
    def call
      parse_options

      eval_path = @options[:eval]
      if eval_path.nil?
        @stdout.puts 'Error: The --eval option is required.'
        @stdout.puts 'Example: bin/evaluate -e evals/skills/infrastructure/rails-api-versioning/api-versioning-with-controller-inheritan'
        return 1
      end

      skill_option = @options[:skill]
      result = Evaluator::Runner.call(
        eval_folder_path: File.expand_path(eval_path),
        skill_path: skill_option ? File.expand_path(skill_option) : nil
      )

      print_results(result)
      return 1 unless result[:success]

      persist_output(result)
      Evaluator::HistoryRecorder.record(
        result,
        source_path: result[:source_path],
        model: Evaluator::Config.model
      )

      0
    end

    private

    def parse_options
      OptionParser.new do |opts|
        opts.banner = 'Usage: evaluate [options]'

        opts.on('-e', '--eval FOLDER',
                'Path to the eval folder (for example evals/skills/... or evals/workflows/...)') do |eval_path|
          @options[:eval] = eval_path
        end

        opts.on('-s', '--skill FOLDER',
                'Optional override for the source skill/workflow folder to hydrate from') do |skill_path|
          @options[:skill] = skill_path
        end

        opts.on('-o', '--output FILE', 'Path to save the JSON report') do |output_path|
          @options[:output] = output_path
        end
      end.parse!(@argv)
    end

    def print_results(result)
      @stdout.puts RESULTS_BANNER

      unless result[:success]
        @stdout.puts "Evaluation failed: #{result[:response][:error][:message]}"
        return
      end

      result[:tasks].each do |task_result|
        @stdout.puts "\n========================================="
        @stdout.puts "       RESULTS: #{task_result[:path]}    "
        @stdout.puts "=========================================\n"
        print_task_result(task_result)
      end
    end

    def print_task_result(task_result)
      score_payload = task_result[:judge_score]
      parsed_judge = parse_judge_score(score_payload)
      unless parsed_judge
        print_parse_error(score_payload)
        return
      end

      print_judge_summary(parsed_judge)
      print_task_diffs(task_result)
    rescue JSON::ParserError
      print_parse_error(task_result[:judge_score])
    end

    def print_parse_error(raw_score)
      @stdout.puts 'Could not parse judge JSON response. Raw output:'
      @stdout.puts(raw_score || 'nil')
    end

    def print_judge_summary(parsed_judge)
      @stdout.puts "Baseline Score: #{parsed_judge['baseline_score']}/100"
      @stdout.puts "Context Score:  #{parsed_judge['context_score']}/100"
      @stdout.puts "\nReasoning:"
      @stdout.puts parsed_judge['reasoning']
    end

    def print_task_diffs(task_result)
      path = task_result[:path]
      sep_newline = "\n========================================="
      sep_plain = "=========================================\n"

      @stdout.puts sep_newline
      @stdout.puts "  BASELINE CHANGES: #{path}  "
      @stdout.puts sep_plain
      @stdout.puts task_result[:baseline_diff]
      @stdout.puts sep_newline
      @stdout.puts "   CONTEXT CHANGES: #{path}  "
      @stdout.puts sep_plain
      @stdout.puts task_result[:context_diff]
    end

    def parse_judge_score(judge_score)
      case judge_score
      when String
        JSON.parse(judge_score)
      when Hash
        judge_score.transform_keys(&:to_s)
      end
    end

    def persist_output(result)
      output_path = @options[:output]
      return unless output_path

      File.write(output_path, JSON.pretty_generate(result))
      @stdout.puts "\nReport saved to #{output_path}"
    end
  end
end
