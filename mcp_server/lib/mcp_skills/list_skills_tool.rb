# frozen_string_literal: true

require 'mcp'
require_relative 'skill_catalog'

module McpSkills
  # MCP Tool that returns structured metadata for public Rails Agent Skills.
  class ListSkillsTool < MCP::Tool
    tool_name 'list_skills'
    title 'List Rails Skills'
    description 'Discover public Rails Agent Skills before loading one with use_skill. ' \
                'Returns names, categories, paths, and routing descriptions only; it does not return full skill bodies. ' \
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
          description: 'Number of public skills returned.'
        },
        skills: {
          type: 'array',
          description: 'Public Rails Agent Skills available through use_skill.',
          items: {
            type: 'object',
            properties: {
              name: { type: 'string', description: 'Stable skill name.' },
              path: { type: 'string', description: 'Repository path to SKILL.md.' },
              category: { type: 'string', description: 'Top-level skill category.' },
              description: { type: 'string', description: 'Short routing description.' }
            },
            required: %w[name path category description],
            additionalProperties: false
          }
        }
      },
      required: %w[count skills],
      additionalProperties: false
    )

    annotations(
      title: 'List Rails Skills',
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    class << self
      # @param project_root [Pathname, String] Override for testing; defaults to repo root.
      # @param server_context [Hash] MCP server context (unused but required by protocol).
      # @return [MCP::Tool::Response]
      # @raise [SkillCatalog::ManifestError] when tile.json cannot be read, parsed, or mapped to skills.
      def call(server_context:, project_root: nil)
        skills = SkillCatalog.call(resolve_root(project_root)).map(&:metadata)
        structured_content = { count: skills.length, skills: skills }
        text = skills.map { |skill| "#{skill[:name]}\t#{skill[:category]}\t#{skill[:description]}" }.join("\n")

        MCP::Tool::Response.new(
          [{ type: 'text', text: text }],
          structured_content: structured_content
        )
      end

      private

      def resolve_root(override)
        return Pathname.new(override) if override

        Pathname.new(__dir__).join('..', '..', '..').realpath
      end
    end
  end
end
