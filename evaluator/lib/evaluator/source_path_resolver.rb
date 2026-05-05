# frozen_string_literal: true

module Evaluator
  # Resolves the source skill or workflow path for a given evaluation target.
  class SourcePathResolver
    # Resolves the source path using either an explicit override or the eval directory convention.
    #
    # @param eval_folder_path [String] Relative path to the eval directory.
    # @param skill_path [String, nil] Optional explicit override for the source directory.
    # @return [String, nil] The resolved source path relative to the evaluator repo root, or nil if unmappable.
    # @example Infer a skill source path
    #   Evaluator::SourcePathResolver.call(
    #     eval_folder_path: 'evals/skills/code-quality/rails-code-review/review-order'
    #   )
    #   # => "skills/code-quality/rails-code-review"
    def self.call(eval_folder_path:, skill_path: nil)
      return skill_path if skill_path && !skill_path.empty?

      segments = eval_folder_path.to_s.split('/').reject(&:empty?)

      if (index = segments.rindex('skills'))
        skill_cat = segments[index + 1]
        skill_name = segments[index + 2]
        return "skills/#{skill_cat}/#{skill_name}" if skill_cat && skill_name
      end

      if (index = segments.rindex('workflows'))
        workflow_name = segments[index + 1]
        return "workflows/#{workflow_name}" if workflow_name
      end

      # Return nil if we can't infer a specific skill/workflow (e.g. batch run on a category)
      # The Runner or Hydrator will handle the lack of context.
      nil
    end
  end
end
