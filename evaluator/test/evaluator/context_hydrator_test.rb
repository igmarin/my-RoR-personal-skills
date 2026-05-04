# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class ContextHydratorTest < Minitest::Test
    def test_call_returns_success_and_hydrated_context
      # Arrange
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'test.md'), 'Dummy skill content')

        # Act
        result = ContextHydrator.call(source_path: '.', base_path: Pathname.new(dir))

        # Assert
        assert result[:success]
        assert_match(/Dummy skill content/, result[:response][:context])
        assert_match(/<agent_context>/, result[:response][:context])
        assert_match(/<file path="test.md">/, result[:response][:context])
      end
    end

    def test_call_returns_error_on_failure
      # Act
      result = ContextHydrator.call(source_path: 'non_existent_path')

      # Assert
      refute result[:success]
      assert_match(/does not exist/, result[:response][:error][:message])
    end
  end
end
