# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class GemspecTest < Minitest::Test
    def setup
      @spec = Gem::Specification.load(File.expand_path('../../agent_evaluator.gemspec', __dir__))
    end

    def test_package_metadata_points_to_project_sources
      assert_equal 'https://github.com/igmarin/rails-agent-skills', @spec.homepage
      assert_equal 'https://github.com/igmarin/rails-agent-skills/tree/main/evaluator',
                   @spec.metadata['source_code_uri']
      assert_equal 'true', @spec.metadata['rubygems_mfa_required']
    end

    def test_package_includes_readme_and_license
      assert_includes @spec.files, 'README.md'
      assert_includes @spec.files, 'LICENSE'
    end
  end
end
