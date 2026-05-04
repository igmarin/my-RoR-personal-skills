# frozen_string_literal: true

require_relative '../client'
require_relative 'tool_executor'

module Evaluator
  class ReactAgent
    # Service object responsible for executing a single step of the ReAct loop.
    class Step
      # Executes one iteration of reasoning and potential tool usage.
      #
      # @param messages [Array<Hash>] The conversation history.
      # @param config [Hash] Configuration for this step (client params, system prompt, working dir).
      # @return [Hash] Step outcome containing :continue (boolean), :result (hash, if finished), and :messages.
      def self.call(messages, config)
        client_result = Client.call(
          system_prompt: config[:system_prompt],
          messages: messages,
          tools: Tools.definitions,
          **config[:client_params]
        )

        return { continue: false, result: client_result } unless client_result[:success]

        response_msg = client_result[:response][:message]
        messages << response_msg

        tool_calls = response_msg['tool_calls']
        content = response_msg['content']

        return { continue: false, result: { success: true, response: { content: content } } } if Array(tool_calls).empty?

        if content
          puts "\n=== Agent Thought ==="
          puts content
        end

        messages.concat(ToolExecutor.call(tool_calls, config[:working_dir]))

        { continue: true, messages: messages }
      end
    end
  end
end
