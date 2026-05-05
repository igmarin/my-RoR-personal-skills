# frozen_string_literal: true

require_relative 'judge_score_parser_service'

module Evaluator
  module Services
    # Service object for printing formatted evaluation results to stdout.
    # Handles result formatting, score parsing, and provides standardized output for
    # both successful and failed evaluations.
    class ResultPrinterService
      RESULTS_BANNER = "\n=========================================\n              " \
                       "RESULTS                    \n" \
                       "=========================================\n"

      # Prints formatted evaluation results to the specified output stream.
      #
      # @param result [Hash] Evaluation result hash containing success status and task data
      # @param stdout [#puts, #write] Output stream for user-visible messages. Defaults to $stdout
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: {} } on successful printing
      # @example Print successful results
      #   result = ResultPrinterService.call(evaluation_result)
      #   # => { success: true, response: {} }
      # @example Print to custom stream
      #   result = ResultPrinterService.call(evaluation_result, stdout: string_io)
      #   # => { success: true, response: {} }
      def self.call(result, stdout: $stdout)
        new(result, stdout: stdout).call
      end

      # Initializes a new result printer instance.
      #
      # @param result [Hash] Evaluation result hash containing success status and task data
      # @param stdout [#puts, #write] Output stream for user-visible messages. Defaults to $stdout
      def initialize(result, stdout: $stdout)
        @result = result
        @stdout = stdout
      end

      # Prints the evaluation results in a formatted, user-friendly manner.
      # Handles both successful evaluations and error cases.
      #
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: {} } on successful printing
      def call
        @stdout.puts RESULTS_BANNER

        unless @result[:success]
          @stdout.puts "Evaluation failed: #{@result[:response][:error][:message]}"
          return { success: true, response: {} }
        end

        @result[:tasks].each do |task_result|
          @stdout.puts "\n========================================="
          @stdout.puts "       RESULTS: #{task_result[:path]}    "
          @stdout.puts "=========================================\n"
          print_task_result(task_result)
        end

        { success: true, response: {} }
      end

      private

      # Prints the result for a single task, including scores and diffs.
      #
      # @param task_result [Hash] Individual task result containing judge scores and diffs
      def print_task_result(task_result)
        score_payload = task_result[:judge_score]
        parser_class = Evaluator::Services::JudgeScoreParserService
        parsed_judge = parser_class.call(score_payload)

        unless parsed_judge[:success]
          print_parse_error
          @stdout.puts(score_payload || 'nil')
          return
        end

        print_judge_summary(parsed_judge[:response])
        print_task_diffs(task_result[:path], task_result[:baseline_diff], task_result[:context_diff])
      end

      # Prints an error message when judge score parsing fails.
      def print_parse_error
        @stdout.puts 'Could not parse judge JSON response. Raw output:'
      end

      # Prints the judge score summary including baseline and context scores.
      #
      # @param parsed_judge [Hash] Parsed judge score data containing scores and reasoning
      def print_judge_summary(parsed_judge)
        @stdout.puts "Baseline Score: #{parsed_judge['baseline_score']}/100"
        @stdout.puts "Context Score:  #{parsed_judge['context_score']}/100"
        @stdout.puts "\nReasoning:"
        @stdout.puts parsed_judge['reasoning']
      end

      # Prints the baseline and context diffs for a task.
      #
      # @param path [String] The file path associated with the diff
      # @param baseline_diff [String] The diff content for the baseline
      # @param context_diff [String] The diff content for the context
      def print_task_diffs(path, baseline_diff, context_diff)
        print_diff_section('BASELINE CHANGES', path, baseline_diff)
        print_diff_section('CONTEXT CHANGES', path, context_diff)
      end

      # Prints a formatted diff section with a banner.
      #
      # @param title [String] The title for the diff section (e.g., 'BASELINE CHANGES')
      # @param path [String] The file path associated with the diff
      # @param diff [String] The diff content to print
      def print_diff_section(title, path, diff)
        sep_newline = "\n========================================="
        sep_plain = "=========================================\n"

        @stdout.puts sep_newline
        @stdout.puts "  #{title}: #{path}  "
        @stdout.puts sep_plain
        @stdout.puts diff
      end
    end
  end
end
