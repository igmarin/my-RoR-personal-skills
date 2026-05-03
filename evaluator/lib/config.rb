# frozen_string_literal: true

module Evaluator
  # Centralized configuration for the Evaluator system.
  # :reek:Attribute
  class Config
    class << self
      attr_accessor :model, :max_execution_time, :openai_api_key, :allowed_commands

      # Allows configuration via a block.
      def setup
        yield(self)
      end

      # Resets the configuration to default values.
      def reset
        @model = 'gpt-4o'
        @max_execution_time = 30
        @openai_api_key = ENV.fetch('OPENAI_API_KEY', nil)
        # If set to an array, acts as a whitelist for commands (e.g. ['rspec', 'ruby', 'ls'])
        @allowed_commands = nil
      end
    end

    reset
  end
end
