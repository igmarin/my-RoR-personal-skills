# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class ReactAgentTest < Minitest::Test
    def test_call_delegates_to_loop_runner
      # Arrange
      expected_config = {
        system_prompt: 'System',
        client_params: { model: 'test' },
        working_dir: '/tmp',
        container_id: nil
      }

      ReactAgent::LoopRunner.expects(:call).with('Initial', 5, expected_config).returns({ success: true })

      # Act
      result = ReactAgent.call(
        system_prompt: 'System',
        initial_prompt: 'Initial',
        max_iterations: 5,
        working_dir: '/tmp',
        client_params: { model: 'test' }
      )

      # Assert
      assert result[:success]
    end
  end
end
