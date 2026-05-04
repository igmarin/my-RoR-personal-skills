# frozen_string_literal: true

module Evaluator
  module Clients
    module Providers
      # Null Object implementation for unsupported LLM providers.
      # Follows the same contract as other clients but returns a failure response.
      class NullClient
        # Standard entry point.
        #
        # @param _system_prompt [String] Ignored.
        # @param _messages [Array<Hash>] Ignored.
        # @param _tools [Array<Hash>] Ignored.
        # @param _options [Hash] Ignored.
        # @return [Hash] failure response contract.
        def self.call(_system_prompt: nil, _messages: [], _tools: [], **_options)
          provider = Evaluator::Config.current_llm_provider
          {
            success: false,
            response: {
              error: {
                message: "Unsupported or unconfigured LLM provider: '#{provider}'"
              }
            }
          }
        end
      end
    end
  end
end
