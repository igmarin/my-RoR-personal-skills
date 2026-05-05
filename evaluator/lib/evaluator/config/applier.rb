# frozen_string_literal: true

module Evaluator
  class Config
    # Applies normalized configuration hashes to a mutable store.
    class Applier
      # Applies configuration values to a store.
      #
      # @param store [Store] mutable configuration store
      # @param data [Hash] normalized configuration values
      # @return [void]
      def self.call(store:, data:)
        new(store:, data:).call
      end

      # Initializes the applier.
      #
      # @param store [Store] mutable configuration store
      # @param data [Hash] normalized configuration values
      # @return [Applier] an applier instance
      def initialize(store:, data:)
        @store = store
        @data = data
      end

      # Applies configuration values to the configured store.
      #
      # @return [void]
      def call
        apply_scalar_values
        apply_provider_values
      end

      private

      def apply_scalar_values
        @store.assign_current_llm_provider(@data[:current_llm_provider].to_sym) if @data.key?(:current_llm_provider)
        @store.assign_max_execution_time(@data[:max_execution_time]) if @data.key?(:max_execution_time)
        @store.assign_allowed_commands(@data[:allowed_commands]) if @data.key?(:allowed_commands)
      end

      def apply_provider_values
        if @data.key?(:llm_providers_config)
          @store.replace_provider_config(Marshal.load(Marshal.dump(@data[:llm_providers_config])))
        else
          @store.apply_provider_config(@data[:providers] || {})
        end
      end
    end
  end
end
