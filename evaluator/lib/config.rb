# frozen_string_literal: true

require 'json'
require 'pathname'

module Evaluator
  # Centralized configuration for the Evaluator system.
  # Supports hierarchical loading: Defaults < Home JSON < Local JSON < ENV Variables.
  # :reek:Attribute
  class Config
    CONFIG_FILENAME = 'evaluator.json'

    class << self
      attr_accessor :current_llm_provider, :max_execution_time, :allowed_commands, :llm_providers_config

      # Allows configuration via a block.
      def setup
        yield(self)
      end

      # Resets the configuration to default values and reloads from files/ENV.
      # The hierarchy is: Code Defaults < ~/.evaluator.json < ./evaluator.json < ENV variables.
      def reset
        apply_defaults
        apply_json_config
        apply_env_overrides
      end

      # Returns the API key for the current LLM provider.
      def api_key
        @llm_providers_config.dig(current_llm_provider, :api_key)
      end

      # Returns the model for the current LLM provider.
      def model
        @llm_providers_config.dig(current_llm_provider, :model)
      end

      # Dynamically sets a specific provider's API key.
      def set_provider_api_key(provider, key)
        @llm_providers_config[provider.to_sym][:api_key] = key
      end

      # Dynamically sets a specific provider's model.
      def set_provider_model(provider, model_name)
        @llm_providers_config[provider.to_sym][:model] = model_name
      end

      # Dynamically sets a specific provider's location (for Gemini).
      def set_provider_location(provider, location_name)
        @llm_providers_config[provider.to_sym][:location] = location_name
      end

      # Dynamically sets a specific provider's project_id (for Gemini).
      def set_provider_project_id(provider, project_id_value)
        @llm_providers_config[provider.to_sym][:project_id] = project_id_value
      end

      private

      # Applies hardcoded base defaults.
      def apply_defaults
        @current_llm_provider = :openai
        @max_execution_time = 30
        @allowed_commands = nil
        @llm_providers_config = {
          openai: { api_key: nil, model: 'gpt-4o' },
          gemini: {
            api_key: nil,
            model: 'gemini-1.5-flash-latest',
            location: 'us-central1',
            project_id: nil
          }
        }
      end

      # Loads and applies JSON configuration files from home and local directories.
      def apply_json_config
        # Load Home config first (lower priority)
        home_config = Pathname.new(Dir.home).join(CONFIG_FILENAME)
        load_and_merge_json(home_config) if home_config.exist?

        # Load Local config (higher priority)
        local_config = Pathname.new(Dir.pwd).join(CONFIG_FILENAME)
        load_and_merge_json(local_config) if local_config.exist?
      end

      # Parses a JSON file and merges it into the current configuration.
      # @param path [Pathname]
      def load_and_merge_json(path)
        data = JSON.parse(File.read(path), symbolize_names: true)

        unless data.is_a?(Hash)
          warn "Warning: Config file at #{path} is not a valid JSON hash. Skipping."
          return
        end

        @current_llm_provider = data[:current_llm_provider].to_sym if data[:current_llm_provider]
        @max_execution_time = data[:max_execution_time] if data[:max_execution_time]
        @allowed_commands = data[:allowed_commands] if data[:allowed_commands]

        providers_data = data[:providers]
        unless providers_data.is_a?(Hash)
          warn "Warning: 'providers' section in config file at #{path} is not a valid hash. Skipping provider merge."
          return
        end

        providers_data.each do |provider, config|
          @llm_providers_config[provider] ||= {}
          @llm_providers_config[provider].merge!(config)
        end
      rescue JSON::ParserError
        warn "Warning: Failed to parse config file at #{path}. It might be malformed or empty."
      end

      # Applies environment variable overrides (highest priority).
      def apply_env_overrides
        override_openai_env
        override_gemini_env
      end

      def override_openai_env
        api_key = ENV.fetch('OPENAI_API_KEY', nil)
        @llm_providers_config[:openai][:api_key] = api_key if api_key
      end

      def override_gemini_env
        config = @llm_providers_config[:gemini]

        api_key = ENV.fetch('GEMINI_API_KEY', nil)
        config[:api_key] = api_key if api_key

        location = ENV.fetch('GEMINI_LOCATION', nil)
        config[:location] = location if location

        project_id = ENV.fetch('GEMINI_PROJECT_ID', nil)
        config[:project_id] = project_id if project_id
      end
    end

    reset
  end
end
