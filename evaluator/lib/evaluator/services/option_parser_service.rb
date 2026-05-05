# frozen_string_literal: true

require 'optparse'

module Evaluator
  module Services
    # Service object for parsing CLI arguments using OptionParser.
    # Provides standardized error handling and response format for command-line options.
    class OptionParserService
      PARSE_ERROR = 'Failed to parse command line options'

      # Parses CLI arguments into a standardized options hash.
      #
      # @param argv [Array<String>] Raw CLI arguments from command line
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: Hash } on success, containing parsed options
      #   - { success: false, response: { error: { message: String } } } on failure
      # @raise [SystemExit] when help flag (-h/--help) is used (normal OptionParser behavior)
      # @example Parse valid arguments
      #   result = OptionParserService.call(['-e', 'evals/test', '-o', 'output.json'])
      #   # => { success: true, response: { eval: 'evals/test', output: 'output.json' } }
      # @example Parse invalid arguments
      #   result = OptionParserService.call(['--invalid-flag'])
      #   # => { success: false, response: { error: { message: 'invalid option: --invalid-flag' } } }
      def self.call(argv)
        new(argv).call
      end

      # Initializes a new option parser instance.
      #
      # @param argv [Array<String>] Raw CLI arguments from command line
      def initialize(argv)
        @argv = argv
        @options = {}
      end

      # Parses the CLI arguments and returns a standardized response.
      #
      # @return [Hash] Standardized response hash with format:
      #   - { success: true, response: Hash } on success, containing parsed options
      #   - { success: false, response: { error: { message: String } } } on failure
      # @raise [OptionParser::ParseError] when invalid options are provided (handled internally)
      def call
        parser = create_option_parser
        parser.parse!(@argv)
        { success: true, response: @options }
      rescue OptionParser::ParseError => e
        { success: false, response: { error: { message: e.message } } }
      end

      private

      # Creates and configures the OptionParser instance with all supported options.
      #
      # @return [OptionParser] Configured parser instance
      def create_option_parser
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
        end
      end
    end
  end
end
