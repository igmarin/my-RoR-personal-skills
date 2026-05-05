# frozen_string_literal: true

require 'json'

module Evaluator
  class Config
    # Loads and normalizes evaluator JSON configuration files.
    class JsonLoader
      # Loads a JSON config file into a normalized hash.
      #
      # @param path [Pathname] path to the JSON configuration file
      # @return [Hash] result envelope with normalized configuration values
      def self.call(path)
        new(path).call
      end

      # Initializes the loader.
      #
      # @param path [Pathname] path to the JSON configuration file
      # @return [JsonLoader] a loader instance
      def initialize(path)
        @path = path
      end

      # Loads a JSON config file into a normalized hash.
      #
      # @return [Hash] result envelope with normalized configuration values
      def call
        data = JSON.parse(File.read(@path), symbolize_names: true)
        return warn_invalid_config unless data.is_a?(Hash)

        success(data.slice(:current_llm_provider, :max_execution_time, :allowed_commands)
                    .compact
                    .merge(providers: normalized_providers(data[:providers])))
      rescue JSON::ParserError => e
        log_parse_error(e)
        failure('Failed to parse config file')
      rescue StandardError => e
        failure(e.message)
      end

      private

      def warn_invalid_config
        warn "Warning: Config file at #{@path} is not a valid JSON hash. Skipping."
        failure('Config file is not a valid JSON hash')
      end

      def normalized_providers(providers_data)
        providers_data ||= {}
        return warn_invalid_providers unless providers_data.is_a?(Hash)

        providers_data.each_with_object({}) do |(provider, config), providers|
          if config.is_a?(Hash)
            providers[provider] = config
          else
            warn "Warning: provider '#{provider}' in config file at #{@path} is not a valid hash. Skipping."
          end
        end
      end

      def warn_invalid_providers
        warn "Warning: 'providers' section in config file at #{@path} is not a valid hash. Skipping provider merge."
        {}
      end

      def log_parse_error(error)
        warn "Warning: Failed to parse config file at #{@path}. It might be malformed or empty."
        warn error.message
        backtrace = Array(error.backtrace).first(5)
        warn backtrace.join("\n") unless backtrace.empty?
      end

      def success(config)
        { success: true, response: { config: config } }
      end

      def failure(message)
        { success: false, response: { error: { message: message } } }
      end
    end
  end
end
