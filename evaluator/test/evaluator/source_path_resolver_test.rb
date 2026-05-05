# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class SourcePathResolverTest < Minitest::Test
    def test_infers_skill_source_path_from_eval_path
      resolved = SourcePathResolver.call(
        eval_folder_path: 'evals/skills/code-quality/rails-code-review/review-order'
      )

      assert_equal 'skills/code-quality/rails-code-review', resolved
    end

    def test_infers_workflow_source_path_from_eval_path
      resolved = SourcePathResolver.call(
        eval_folder_path: 'evals/workflows/rails-tdd-loop/full-feature'
      )

      assert_equal 'workflows/rails-tdd-loop', resolved
    end

    def test_prefers_explicit_override
      resolved = SourcePathResolver.call(
        eval_folder_path: 'evals/workflows/rails-tdd-loop/full-feature',
        skill_path: 'skills/patterns/ruby-service-objects'
      )

      assert_equal 'skills/patterns/ruby-service-objects', resolved
    end

    def test_returns_nil_for_unmapped_eval_path_without_override
      resolved = SourcePathResolver.call(eval_folder_path: 'tmp/custom-evals/example')

      assert_nil resolved
    end
  end
end
