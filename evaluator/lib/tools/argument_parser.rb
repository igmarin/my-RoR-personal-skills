# frozen_string_literal: true

require 'json'

module Evaluator
  module Tools
    # Parses JSON arguments for tools, handling format errors gracefully.
    class ArgumentParser
      # Parses a JSON string of arguments.
      #
      # @param arguments [String] The JSON string to parse.
      # @return [Hash, String] The parsed arguments hash, or an error message string.
      def self.call(arguments)
        JSON.parse(arguments)
      rescue JSON::ParserError => e
        "Error executing tool: Invalid JSON format for arguments. Please correct it. Details: #{e.message}"
      end
    end
  end
end
