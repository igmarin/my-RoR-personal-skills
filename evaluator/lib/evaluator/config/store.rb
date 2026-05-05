# frozen_string_literal: true

module Evaluator
  class Config
    # Holds mutable evaluator configuration state behind the Config facade.
    class Store
      # Returns the current provider name.
      #
      # @return [Symbol, nil] current provider
      attr_reader :current_llm_provider

      # Returns the maximum command execution time.
      #
      # @return [Integer, nil] maximum execution time in seconds
      attr_reader :max_execution_time

      # Returns the allowed command list.
      #
      # @return [Array<String>, nil] allowed commands
      attr_reader :allowed_commands

      # Returns provider configuration.
      #
      # @return [Hash, nil] provider configuration by provider name
      attr_reader :llm_providers_config

      def initialize
        @llm_providers_config = {}
      end

      # Returns the API key for the current provider.
      #
      # @return [String, nil] configured API key
      def api_key
        llm_providers_config.dig(current_llm_provider, :api_key)
      end

      # Returns the model for the current provider.
      #
      # @return [String, nil] configured model name
      def model
        llm_providers_config.dig(current_llm_provider, :model)
      end

      # Applies provider-specific configuration values.
      #
      # @param providers [Hash] provider configuration by provider name
      # @return [Hash] provider configuration
      def apply_provider_config(providers)
        providers.each do |provider, config|
          provider_config(provider).merge!(config)
        end
      end

      # Sets one provider-specific configuration value.
      #
      # @param provider [String, Symbol] provider name
      # @param setting [Symbol] provider setting name
      # @param value [Object] provider setting value
      # @return [Object] assigned value
      def set_provider_setting(provider, setting, value)
        provider_config(provider)[setting] = value
      end

      # Sets the current provider.
      #
      # @param value [String, Symbol] provider name
      # @return [Symbol, nil] assigned provider
      def assign_current_llm_provider(value)
        [value.to_s.strip].grep_v('').each { |provider_name| @current_llm_provider = provider_name.to_sym }
        @current_llm_provider
      end

      # Sets maximum command execution time.
      #
      # @param value [Integer] maximum execution time in seconds
      # @return [Integer] assigned maximum execution time
      def assign_max_execution_time(value)
        @max_execution_time = value
      end

      # Sets allowed commands.
      #
      # @param value [Array<String>, nil] allowed command list
      # @return [Array<String>, nil] assigned allowed commands
      def assign_allowed_commands(value)
        @allowed_commands = value
      end

      # Sets provider configuration.
      #
      # @param value [Hash] provider configuration
      # @return [Hash] assigned provider configuration
      def replace_provider_config(value)
        @llm_providers_config = value
      end

      private

      def provider_config(provider)
        @llm_providers_config ||= {}
        @llm_providers_config[provider.to_sym] ||= {}
      end
    end
  end
end
