# frozen_string_literal: true

require 'pathname'
require_relative 'skill_resource_builder'
require_relative 'doc_resource_builder'
require_relative 'resource_discovery'

module McpSkills
  # Single source of truth for all MCP resources exposed by this server.
  # Scans the repository root for published skills, workflows, and docs.
  # Published locations are discovered centrally so runtime and docs stay aligned.
  class ResourceRegistry
    class NotFoundError < StandardError; end

    # @param project_root [Pathname, String] Root of the rails-agent-skills repository.
    def initialize(project_root)
      @project_root = Pathname.new(project_root)
      @discovery = ResourceDiscovery.call(@project_root)
    end

    # Returns all MCP::Resource objects (skills + docs + workflows).
    # @return [Array<MCP::Resource>]
    def all_resources
      skill_resources + doc_resources + workflow_resources
    end

    # Reads a resource by URI and returns the MCP resources/read payload.
    # @param uri [String] file:// URI of the resource.
    # @return [Array<Hash>] Array with one hash containing :uri, :mimeType, :text.
    # @raise [NotFoundError] if the URI is not a known registered resource.
    def read(uri)
      resource = all_resources.find { |r| r.uri == uri }
      raise NotFoundError, "Resource not found: #{uri}" unless resource

      file_path = uri.sub('file://', '')
      [{ uri: uri, mimeType: resource.mime_type, text: File.read(file_path) }]
    end

    private

    def skill_resources
      @discovery.skill_dirs.flat_map { |dir| SkillResourceBuilder.call(dir) }
    end

    def doc_resources
      DocResourceBuilder.call(@discovery.docs_dir, prefix: 'doc')
    end

    def workflow_resources
      @discovery.workflow_dirs.flat_map { |dir| SkillResourceBuilder.call(dir, prefix: 'workflow') }
    end
  end
end
