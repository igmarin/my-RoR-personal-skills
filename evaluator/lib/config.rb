# frozen_string_literal: true

require 'pathname'
require_relative 'evaluator/config/defaults'
require_relative 'evaluator/config/store'
require_relative 'evaluator/config/applier'
require_relative 'evaluator/config/json_loader'
require_relative 'evaluator/config/env_overrides'
require_relative 'evaluator/config/facade_readers'
require_relative 'evaluator/config/facade_writers'

module Evaluator
  # Centralized configuration for the Evaluator system.
  # Supports hierarchical loading: Defaults < Home JSON < Local JSON < ENV Variables.
  # :reek:Attribute
  class Config
    # File name used for local and home evaluator configuration.
    CONFIG_FILENAME = 'evaluator.json'

    class << self
      include Config::FacadeReaders
      include Config::FacadeWriters

      # Returns the mutable configuration store behind the facade.
      #
      # @return [Config::Store] configuration state store
      def store
        @store ||= Config::Store.new
      end

      # Allows callers to mutate configuration through the facade.
      #
      # @yieldparam config [Class] the Config class facade
      # @return [void]
      # @raise [StandardError] if the user-supplied block raises
      def setup
        yield(self)
      end

      # Resets the configuration to default values and reloads from files/ENV.
      # The hierarchy is: Code Defaults < ~/.evaluator.json < ./evaluator.json < ENV variables.
      #
      # @return [void]
      # @raise [Errno::ENOENT] if a discovered config file disappears before it can be read
      def reset
        apply_defaults
        apply_json_config
        apply_env_overrides
      end

      private

      def apply_defaults
        apply_config(Config::Defaults.call[:response][:config])
      end

      def apply_json_config
        config_paths.each do |path|
          apply_config_result(Config::JsonLoader.call(path)) if path.exist?
        end
      end

      def apply_env_overrides
        result = Config::EnvOverrides.call
        store.apply_provider_config(result[:response][:overrides]) if result[:success]
      end

      def config_paths
        [
          Pathname.new(Dir.home).join(CONFIG_FILENAME),
          Pathname.new(Dir.pwd).join(CONFIG_FILENAME)
        ]
      end

      def apply_config(data)
        Config::Applier.call(store:, data:)
      end

      def apply_config_result(result)
        apply_config(result[:response][:config]) if result[:success]
      end
    end

    reset
  end
end
