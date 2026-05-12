# frozen_string_literal: true

require 'mcp'
require_relative 'skill_catalog'

module McpSkills
  # MCP Tool that returns the content of a SKILL.md given a skill name.
  # The agent invokes this tool by name ('use_skill') with a skill_name argument.
  class SkillTool < MCP::Tool
    tool_name 'use_skill'
    title 'Use Rails Skill'
    description 'Read one public Rails Agent Skill by name after selecting it from list_skills. ' \
                'Returns the full SKILL.md instructions plus structured metadata. ' \
                'This tool is read-only and has no repository side effects.'

    input_schema(
      properties: {
        'skill_name' => {
          type: 'string',
          description: 'The directory name of the skill (e.g. "code-review", "write-tests")'
        }
      },
      required: ['skill_name']
    )

    output_schema(
      properties: {
        found: {
          type: 'boolean',
          description: 'Whether the requested skill was found.'
        },
        name: {
          type: %w[string null],
          description: 'Normalized skill name, or null when not found.'
        },
        path: {
          type: %w[string null],
          description: 'Repository path to SKILL.md, or null when not found.'
        },
        category: {
          type: %w[string null],
          description: 'Skill category, or null when not found.'
        },
        description: {
          type: %w[string null],
          description: 'Short routing description, or null when not found.'
        },
        content: {
          type: %w[string null],
          description: 'Full SKILL.md instructions, or null when not found.'
        },
        error: {
          type: %w[string null],
          description: 'Error message when the skill cannot be loaded.'
        }
      },
      required: %w[found name path category description content error],
      additionalProperties: false
    )

    annotations(
      title: 'Use Rails Skill',
      read_only_hint: true,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    class << self
      # @param skill_name [String] The skill directory name.
      # @param project_root [Pathname, String] Override for testing; defaults to repo root.
      # @param server_context [Hash] MCP server context (unused but required by protocol).
      # @return [MCP::Tool::Response]
      def call(skill_name:, server_context:, project_root: nil)
        root = resolve_root(project_root)

        name = normalize_skill_name(skill_name)
        skill = SkillCatalog.call(root).find { |candidate| candidate.name == name }

        unless skill
          structured_content = not_found_content(name)
          return MCP::Tool::Response.new(
            [{ type: 'text', text: structured_content[:error] }],
            error: true,
            structured_content: structured_content
          )
        end

        unless skill.content
          structured_content = not_found_content(name, "Skill '#{name}' has no SKILL.md.")
          return MCP::Tool::Response.new(
            [{ type: 'text', text: structured_content[:error] }],
            error: true,
            structured_content: structured_content
          )
        end

        structured_content = {
          found: true,
          name: skill.name,
          path: skill.path,
          category: skill.category,
          description: skill.description,
          content: skill.content,
          error: nil
        }

        MCP::Tool::Response.new(
          [{ type: 'text', text: skill.content }],
          structured_content: structured_content
        )
      rescue StandardError => e
        structured_content = not_found_content(name || skill_name, "Error reading skill '#{name || skill_name}': #{e.message}")
        MCP::Tool::Response.new(
          [{ type: 'text', text: structured_content[:error] }],
          error: true,
          structured_content: structured_content
        )
      end

      private

      def normalize_skill_name(skill_name)
        parts = skill_name.to_s.strip.split('/').reject(&:empty?)
        return '' if parts.empty?
        return parts[-2].to_s if parts.last == 'SKILL.md'

        parts.last.to_s
      end

      def not_found_content(name, message = "Skill '#{name}' not found.")
        {
          found: false,
          name: nil,
          path: nil,
          category: nil,
          description: nil,
          content: nil,
          error: message
        }
      end

      def resolve_root(override)
        return Pathname.new(override) if override

        Pathname.new(__dir__).join('..', '..', '..').realpath
      end
    end
  end
end
