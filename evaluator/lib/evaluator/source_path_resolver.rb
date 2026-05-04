# frozen_string_literal: true

module Evaluator
  # Resolves the source skill or workflow path for a given evaluation target.
  class SourcePathResolver
    # Resolves the source path using either an explicit override or the eval directory convention.
    #
    # @param eval_folder_path [String] Relative path to the eval directory.
    # @param skill_path [String, nil] Optional explicit override for the source directory.
    # @return [String] The resolved source path relative to the evaluator repo root.
    # @raise [ArgumentError] when the eval path does not match a supported convention.
    # @example Infer a skill source path
    #   Evaluator::SourcePathResolver.call(
    #     eval_folder_path: 'evals/skills/code-quality/rails-code-review/review-order'
    #   )
    #   # => "skills/code-quality/rails-code-review"
    def self.call(eval_folder_path:, skill_path: nil)
      return skill_path if skill_path && !skill_path.empty?

      segments = eval_folder_path.to_s.split('/').reject(&:empty?)

      if (index = segments.index('skills')) && segments[index + 1] && segments[index + 2]
        return "skills/#{segments[index + 1]}/#{segments[index + 2]}"
      end

      if (index = segments.index('workflows')) && segments[index + 1]
        return "workflows/#{segments[index + 1]}"
      end

      raise ArgumentError, "Could not infer source path from eval target: #{eval_folder_path}"
    end
  end
end
