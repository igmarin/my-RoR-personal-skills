# frozen_string_literal: true

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
        parsed_judge = JudgeScoreParserService.call(score_payload)

        unless parsed_judge[:success]
          print_parse_error(score_payload)
          return
        end

        print_judge_summary(parsed_judge[:response])
        print_task_diffs(task_result)
      end

      # Prints an error message when judge score parsing fails.
      #
      # @param raw_score [String, nil] The raw score that failed to parse
      def print_parse_error(raw_score)
        @stdout.puts 'Could not parse judge JSON response. Raw output:'
        @stdout.puts(raw_score || 'nil')
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
      # @param task_result [Hash] Task result containing diff information
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
    end
  end
end
