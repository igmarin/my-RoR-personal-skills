# frozen_string_literal: true

require 'mcp'

module McpSkills
  # Builds MCP::Resource objects for markdown files under a documentation directory.
  class DocResourceBuilder
    # @param dir [Pathname, String] Directory to scan recursively for .md files.
    # @param prefix [String] Resource name prefix (e.g. 'doc' or 'workflow').
    # @return [Array<MCP::Resource>]
    # @raise [TypeError] when `dir` cannot be converted into a pathname.
    def self.call(dir, prefix:)
      new(Pathname.new(dir), prefix: prefix).build
    end

    # @param dir [Pathname] Directory to scan recursively for .md files.
    # @param prefix [String] Resource name prefix (e.g. 'doc' or 'workflow').
    # @return [void]
    # @raise [TypeError] when `dir` cannot be converted into a pathname.
    def initialize(dir, prefix:)
      @dir = Pathname.new(dir)
      @prefix = prefix
    end

    # Builds documentation resources rooted at the configured directory.
    #
    # @return [Array<MCP::Resource>] One resource per markdown file under the directory.
    # @raise [Errno::ENOENT] when a discovered markdown file disappears before its real path is resolved.
    def build
      return [] unless @dir.exist? && @dir.directory?

      @dir.glob('**/*.md').sort.map do |path|
        slug = path.relative_path_from(@dir).sub_ext('').to_s
        name = "#{@prefix}/#{slug}"
        MCP::Resource.new(
          uri: "file://#{path.realpath}",
          name: name,
          title: name,
          description: "#{@prefix.capitalize}: #{slug}",
          mime_type: 'text/markdown'
        )
      end
    end
  end
end
