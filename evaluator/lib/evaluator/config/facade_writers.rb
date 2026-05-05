# frozen_string_literal: true

module Evaluator
  class Config
    # Writer methods exposed by the Config facade.
    module FacadeWriters
      # Public writer method names mapped to provider setting keys.
      PROVIDER_SETTINGS = {
        api_key: :api_key,
        model: :model,
        location: :location,
        project_id: :project_id
      }.freeze

      # Dynamically sets a specific provider's API key.
      #
      # @param provider [String, Symbol] provider name
      # @param key [String, nil] provider API key
      # @return [String, nil] assigned API key
      def set_provider_api_key(provider, key)
        set_provider_setting(provider, PROVIDER_SETTINGS.fetch(:api_key), key)
      end

      # Dynamically sets a specific provider's model.
      #
      # @param provider [String, Symbol] provider name
      # @param model_name [String] provider model name
      # @return [String] assigned model name
      def set_provider_model(provider, model_name)
        set_provider_setting(provider, PROVIDER_SETTINGS.fetch(:model), model_name)
      end

      # Dynamically sets a specific provider's location.
      #
      # @param provider [String, Symbol] provider name
      # @param location_name [String] provider location
      # @return [String] assigned location
      def set_provider_location(provider, location_name)
        set_provider_setting(provider, PROVIDER_SETTINGS.fetch(:location), location_name)
      end

      # Dynamically sets a specific provider's project ID.
      #
      # @param provider [String, Symbol] provider name
      # @param project_id_value [String, nil] provider project ID
      # @return [String, nil] assigned project ID
      def set_provider_project_id(provider, project_id_value)
        set_provider_setting(provider, PROVIDER_SETTINGS.fetch(:project_id), project_id_value)
      end

      # Sets the current LLM provider.
      #
      # @param value [String, Symbol] provider name
      # @return [String, Symbol] assigned provider name
      def current_llm_provider=(value)
        store.assign_current_llm_provider(value)
      end

      # Sets the maximum command execution time.
      #
      # @param value [Integer] maximum execution time in seconds
      # @return [Integer] assigned maximum execution time
      def max_execution_time=(value)
        store.assign_max_execution_time(value)
      end

      # Sets the allowed command list.
      #
      # @param value [Array<String>, nil] allowed command list
      # @return [Array<String>, nil] assigned allowed commands
      def allowed_commands=(value)
        store.assign_allowed_commands(value)
      end

      # Replaces provider configuration.
      #
      # @param value [Hash] provider configuration
      # @return [Hash] assigned provider configuration
      def llm_providers_config=(value)
        store.replace_provider_config(value)
      end

      private

      def set_provider_setting(provider, setting, value)
        store.set_provider_setting(provider, setting, value)
      end
    end
  end
end
