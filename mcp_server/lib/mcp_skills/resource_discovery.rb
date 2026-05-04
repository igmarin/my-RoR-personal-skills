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
    # @raise [TypeError] when one of the configured path roots cannot be converted into a pathname.
    def call
      Result.new(
        skill_dirs: discover_skill_dirs,
        workflow_dirs: discover_workflow_dirs,
        docs_dir: @project_root.join('docs')
      )
    end

    private

    def discover_skill_dirs
      SKILL_PATTERNS.flat_map { |pattern| @project_root.glob(pattern) }
                    .sort_by { |path| [sort_weight(path), path.to_s] }
                    .map(&:dirname)
                    .reject { |dir| EXCLUDED_DIRS.include?(dir.basename.to_s) }
                    .uniq { |dir| dir.basename.to_s }
    end

    def discover_workflow_dirs
      @project_root.glob(WORKFLOW_PATTERN).sort.map(&:dirname)
    end

    def sort_weight(path)
      path.to_s.include?('/.tessl/') ? 1 : 0
    end
  end
end
