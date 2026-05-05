# frozen_string_literal: true

module Evaluator
  # Resolves the source skill or workflow path for a given evaluation target.
  class SourcePathResolver
    # Resolves the source path using either an explicit override or the eval directory convention.
    #
    # @param eval_folder_path [String] Relative path to the eval directory.
    # @param skill_path [String, nil] Optional explicit override for the source directory.
    # @return [String, nil] The resolved source path relative to the evaluator repo root, or nil if unmappable.
    # @example Infer a skill source path (NEW format):
    #   Evaluator::SourcePathResolver.call(
    #     eval_folder_path: 'evals/skills/rails-code-review/review-order'
    #   )
    #   # => "skills/rails-code-review"
    # @example Infer a skill source path (OLD format, returns category):
    #   Evaluator::SourcePathResolver.call(
    #     eval_folder_path: 'evals/skills/code-quality/rails-code-review/review-order'
    #   )
    #   # => "skills/code-quality/rails-code-review"
    def self.call(eval_folder_path:, skill_path: nil)
      return skill_path if skill_path && !skill_path.empty?

      segments = eval_folder_path.to_s.split('/').reject(&:empty?)

      resolve_skills_path(segments) || resolve_workflows_path(segments)
    end

    private_class_method def self.resolve_skills_path(segments)
      return nil unless (index = segments.rindex('skills'))

      remaining = segments[(index + 1)..]
      resolve_old_format_skills(remaining) || resolve_new_format_skills(remaining)
    end

    private_class_method def self.resolve_old_format_skills(remaining)
      return nil unless remaining.size >= 3

      category = remaining[0]
      skill_name = remaining[1]
      "skills/#{category}/#{skill_name}"
    end

    private_class_method def self.resolve_new_format_skills(remaining)
      return nil unless remaining.size >= 1

      skill_name = remaining[0]
      "skills/#{skill_name}"
    end

    private_class_method def self.resolve_workflows_path(segments)
      return nil unless (index = segments.rindex('workflows'))

      workflow_name = segments[index + 1]
      "workflows/#{workflow_name}" if workflow_name
    end
  end
end
