# frozen_string_literal: true

require 'test_helper'

module Evaluator
  class GemspecTest < Minitest::Test
    def setup
      Dir.chdir(File.expand_path('../../..', __dir__)) do
        @spec = Gem::Specification.load('evaluator/rails-agent-eval.gemspec')
      end
    end

    def test_package_metadata_points_to_project_sources
      assert_equal 'https://github.com/igmarin/rails-agent-eval', @spec.homepage
      assert_equal 'https://github.com/igmarin/rails-agent-eval',
                   @spec.metadata['source_code_uri']
      assert_equal 'true', @spec.metadata['rubygems_mfa_required']
    end

    def test_package_includes_readme_and_license
      assert_includes @spec.files, 'README.md'
      assert_includes @spec.files, 'LICENSE'
    end

    def test_package_includes_evaluator_lib_files_when_loaded_from_repo_root
      assert_includes @spec.files, 'lib/evaluator/version.rb'
      assert_includes @spec.files, 'lib/runner.rb'
    end

    def test_package_includes_readme_linked_docs
      assert_includes @spec.files, 'docs/architecture.md'
      assert_includes @spec.files, 'docs/testing-guide.md'
    end
  end
end
