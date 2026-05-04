# frozen_string_literal: true

require 'pathname'

module McpSkills
  # Discovers the repository paths that should be exposed through MCP resources.
  class ResourceDiscovery
    EXCLUDED_DIRS = %w[skill-template rails-agent-skills mcp_server].freeze
    SKILL_PATTERNS = [
      'build/SKILL.md',
      'skills/*/*/SKILL.md',
      '.tessl/tiles/*/*/*/SKILL.md'
    ].freeze
    WORKFLOW_PATTERN = 'workflows/*/SKILL.md'

    Result = Struct.new(:skill_dirs, :workflow_dirs, :docs_dir, keyword_init: true)

    # Resolves the current resource topology for the repository.
    #
    # @param project_root [String, Pathname] Root of the repository to scan.
    # @return [Result] The discovered skill directories, workflow directories, and docs directory.
    # @raise [TypeError] when `project_root` cannot be converted into a pathname.
    def self.call(project_root)
      new(project_root).call
    end

    # @param project_root [String, Pathname] Root of the repository to scan.
    # @return [void]
    # @raise [TypeError] when `project_root` cannot be converted into a pathname.
    def initialize(project_root)
      @project_root = Pathname.new(project_root)
    end

    # Performs path discovery for MCP resources.
    #
    # @return [Result] The discovered skill directories, workflow directories, and docs directory.
    def call
      Result.new(
        skill_dirs: discover_skill_dirs,
        workflow_dirs: discover_workflow_dirs,
        docs_dir: @project_root.join('docs')
      )
    end

    private

    def discover_skill_dirs
      grouped_dirs = SKILL_PATTERNS.flat_map { |pattern| @project_root.glob(pattern) }
                                  .sort_by { |path| [sort_weight(path), path.to_s] }
                                  .map(&:dirname)
                                  .reject { |dir| EXCLUDED_DIRS.include?(dir.basename.to_s) }
                                  .group_by { |dir| dir.basename.to_s }

      grouped_dirs.values.flat_map { |dirs| deduplicate_dirs(dirs) }
    end

    def deduplicate_dirs(dirs)
      non_tessl_dirs, tessl_dirs = dirs.partition { |dir| sort_weight(dir) == 0 }
      warn_on_duplicate_non_tessl_dirs(non_tessl_dirs)

      return non_tessl_dirs if non_tessl_dirs.any?

      tessl_dirs.first ? [tessl_dirs.first] : []
    end

    def warn_on_duplicate_non_tessl_dirs(non_tessl_dirs)
      return unless non_tessl_dirs.size > 1

      warn "Duplicate published skill names detected: #{non_tessl_dirs.map(&:to_s).join(', ')}"
    end

    def discover_workflow_dirs
      @project_root.glob(WORKFLOW_PATTERN).sort.map(&:dirname)
    end

    def sort_weight(path)
      path.to_s.include?('/.tessl/') ? 1 : 0
    end
  end
end
