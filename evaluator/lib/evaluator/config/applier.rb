# frozen_string_literal: true

module Evaluator
  class Config
    # Applies normalized configuration hashes to a mutable store.
    class Applier
      # Applies configuration values to a store.
      #
      # @param store [Store] mutable configuration store
      # @param data [Hash] normalized configuration values
      # @return [Hash] result envelope with applied status
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
      # @return [Hash] result envelope with applied status
      def call
        apply_scalar_values
        apply_provider_values
        { success: true, response: { applied: true } }
      rescue StandardError => e
        { success: false, response: { error: { message: e.message } } }
      end

      private

      def apply_scalar_values
        assign_current_provider
        @store.assign_max_execution_time(@data[:max_execution_time]) if @data.key?(:max_execution_time)
        @store.assign_allowed_commands(@data[:allowed_commands]) if @data.key?(:allowed_commands)
      end

      def apply_provider_values
        if @data.key?(:llm_providers_config)
          @store.replace_provider_config(copied_provider_config)
        else
          @store.apply_provider_config(@data[:providers] || {})
        end
      end

      def assign_current_provider
        provider = @data.fetch(:current_llm_provider) { return }
        provider_name = provider.to_s.strip
        return if provider_name.empty?

        @store.assign_current_llm_provider(provider_name.to_sym)
      end

      def copied_provider_config
        @data[:llm_providers_config].transform_values(&:dup)
      end
    end
  end
end
