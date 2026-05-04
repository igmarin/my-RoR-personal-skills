# frozen_string_literal: true

require 'pathname'

module Evaluator
  # Responsible for loading source context files (markdown files) from a given path
  # and wrapping them in XML tags for injection into the LLM system prompt.
  class ContextHydrator
    HYDRATION_FAILED = 'Failed to hydrate context from source path'

    # Loads and formats source context files.
    #
    # @param params [Hash] The configuration for context hydration.
    # @option params [String] :source_path The path to the source directory containing markdown files.
    # @option params [String] :skill_path Deprecated alias for `:source_path`.
    # @option params [Pathname, String] :base_path (optional) The base path to resolve the source directory against.
    # @return [Hash] A result hash with :success, and :response containing the XML formatted context.
    # @raise [StandardError] when filesystem access fails before the error is normalized into the response hash.
    def self.call(params)
      new(params).call
    end

    # @param params [Hash] The configuration for context hydration.
    # @return [void]
    # @raise [TypeError] when the provided source or base path cannot be converted into a pathname.
    def initialize(params)
      @source_path = params[:source_path] || params[:skill_path]
      @base_path = params[:base_path] || Pathname.new(File.expand_path('../../', __dir__))
    end

    # Performs the hydration process.
    #
    # @return [Hash] The standardized result hash indicating success or failure.
    # @raise [StandardError] when filesystem access fails before the error is normalized into the response hash.
    def call
      return missing_path_result unless @source_path

      full_path = @base_path.join(@source_path)

      return missing_path_result unless full_path.exist? && full_path.directory?

      md_files = Dir.glob(full_path.join('*.md'))
      xml_context = build_xml(md_files)

      { success: true, response: { context: xml_context } }
    rescue StandardError => e
      Rails.logger.error("Hydration Error: #{e.message}") if defined?(Rails)
      { success: false, response: { error: { message: e.message } } }
    end

    private

    def missing_path_result
      { success: false, response: { error: { message: "Source path #{@source_path} does not exist or is not a directory" } } }
    end

    # Builds the XML structure wrapping the contents of the markdown files.
    #
    # @param md_files [Array<String>] List of absolute paths to markdown files.
    # @return [String] The combined XML representation of the file contents.
    def build_xml(md_files)
      return '' if md_files.empty?

      xml = ['<agent_context>']

      md_files.each do |file_path|
        relative_path = Pathname.new(file_path).relative_path_from(@base_path).to_s
        content = File.read(file_path)

        xml << "  <file path=\"#{relative_path}\">"
        xml << content.gsub(/^/, '    ') # indent content for readability
        xml << '  </file>'
      end

      xml << '</agent_context>'
      xml.join("\n")
    end
  end
end
