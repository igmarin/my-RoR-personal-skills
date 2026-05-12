# frozen_string_literal: true

require 'json'
require 'pathname'
require 'yaml'

module McpSkills
  # Builds structured metadata for public Rails Agent Skills.
  class SkillCatalog
    Skill = Struct.new(:name, :path, :category, :description, :content, keyword_init: true) do
      def metadata
        {
          name: name,
          path: path,
          category: category,
          description: description
        }
      end
    end

    def self.call(project_root)
      new(project_root).call
    end

    def initialize(project_root)
      @project_root = Pathname.new(project_root)
    end

    def call
      manifest.fetch('skills').map { |name, spec| build_skill(name, spec) }
    end

    private

    def manifest
      JSON.parse(@project_root.join('tile.json').read)
    end

    def build_skill(name, spec)
      relative_path = spec.fetch('path')
      skill_md = @project_root.join(relative_path)
      content = skill_md.exist? ? skill_md.read : nil

      Skill.new(
        name: name,
        path: relative_path,
        category: category_from_path(relative_path),
        description: description_from(content.to_s),
        content: content
      )
    end

    def category_from_path(path)
      return 'build' if path == 'build/SKILL.md'

      parts = path.split('/')
      return parts[1] if parts[0] == 'skills' && parts[1]
      return 'workflow' if parts[0] == 'workflows'

      'unknown'
    end

    def description_from(content)
      frontmatter = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)&.[](1)
      return '' unless frontmatter

      metadata = YAML.safe_load(frontmatter, permitted_classes: [], aliases: false) || {}
      metadata.fetch('description', '').to_s.lines.map(&:strip).reject(&:empty?).join(' ')
    rescue Psych::SyntaxError
      ''
    end
  end
end
