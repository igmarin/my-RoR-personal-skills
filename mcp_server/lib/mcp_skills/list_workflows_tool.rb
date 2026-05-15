# frozen_string_literal: true

require 'mcp'
require 'yaml'
require_relative 'resource_discovery'

module McpSkills
  # MCP Tool that returns structured metadata for available Rails Agent Workflows.
  class ListWorkflowsTool < MCP::Tool
    tool_name 'list_workflows'
    title 'List Rails Workflows'
    description 'Discover available Rails Agent Workflows before loading one with use_workflow. ' \
                'Returns names (without -workflow suffix), paths, descriptions, and keywords only; it does not return full workflow bodies. ' \
                'This tool is read-only and has no repository side effects.'

    input_schema(
      properties: {},
      additionalProperties: false
    )

    output_schema(
      properties: {
        count: {
          type: 'integer',
          minimum: 0,
          description: 'Number of workflows returned.'
        },
        workflows: {
          type: 'array',
          description: 'Rails Agent Workflows available through use_workflow.',
          items: {
            type: 'object',
            properties: {
              name: { type: 'string', description: 'Workflow directory name.' },
              path: { type: 'string', description: 'Repository path to SKILL.md.' },
              description: { type: 'string', description: 'Short routing description.' },
              keywords: { type: 'string', description: 'Comma-separated discovery keywords.' }
            },
            required: %w[name path description keywords],
            additionalProperties: false
          }
        }
      },
      required: %w[count workflows],
      additionalProperties: false
    )

    annotations(
      title: 'List Rails Workflows',
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    class << self
      # @param project_root [Pathname, String] Override for testing; defaults to repo root.
      # @param server_context [Hash] MCP server context (unused but required by protocol).
      # @return [MCP::Tool::Response]
      def call(server_context:, project_root: nil)
        root = resolve_root(project_root)
        workflow_dirs = ResourceDiscovery.call(root).workflow_dirs
        workflows = workflow_dirs.map { |dir| build_workflow_metadata(dir, root) }
        structured_content = { count: workflows.length, workflows: workflows }
        text = workflows.map { |w| "#{w[:name]}\t#{w[:description]}" }.join("\n")

        MCP::Tool::Response.new(
          [{ type: 'text', text: text }],
          structured_content: structured_content
        )
      end

      private

      def build_workflow_metadata(dir, root)
        skill_md = dir.join('SKILL.md')
        content = skill_md.exist? ? skill_md.read : ''
        frontmatter = parse_frontmatter(content)

        {
          name: dir.basename.to_s,
          path: skill_md.relative_path_from(root).to_s,
          description: frontmatter_description(frontmatter),
          keywords: frontmatter_keywords(frontmatter)
        }
      end

      def parse_frontmatter(content)
        match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
        return {} unless match

        YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
      rescue Psych::SyntaxError
        {}
      end

      def frontmatter_description(frontmatter)
        frontmatter.fetch('description', '').to_s.lines.map(&:strip).reject(&:empty?).join(' ')
      end

      def frontmatter_keywords(frontmatter)
        raw = frontmatter['keywords'] || frontmatter.dig('metadata', 'keywords') || ''
        raw.to_s.strip
      end

      def resolve_root(override)
        return Pathname.new(override) if override

        Pathname.new(__dir__).join('..', '..', '..').realpath
      end
    end
  end
end
