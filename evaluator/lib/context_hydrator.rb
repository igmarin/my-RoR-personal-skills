# frozen_string_literal: true

require "pathname"

module Evaluator
  class ContextHydrator
    def initialize(base_path = nil)
      @base_path = base_path || Pathname.new(File.expand_path("../../", __dir__))
    end

    def hydrate(skill_path)
      full_path = @base_path.join(skill_path)
      
      unless full_path.exist? && full_path.directory?
        raise ArgumentError, "Skill path #{skill_path} does not exist or is not a directory"
      end

      md_files = Dir.glob(full_path.join("*.md")).sort

      build_xml(skill_path, md_files)
    end

    private

    def build_xml(skill_path, md_files)
      return "" if md_files.empty?

      xml = ["<agent_context>"]
      
      md_files.each do |file_path|
        relative_path = Pathname.new(file_path).relative_path_from(@base_path).to_s
        content = File.read(file_path)
        
        xml << "  <file path=\"#{relative_path}\">"
        xml << content.gsub(/^/, "    ") # indent content for readability
        xml << "  </file>"
      end
      
      xml << "</agent_context>"
      xml.join("\n")
    end
  end
end
