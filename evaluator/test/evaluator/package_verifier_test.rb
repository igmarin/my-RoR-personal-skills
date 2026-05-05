# frozen_string_literal: true

require 'test_helper'
require 'rubygems/package'

module Evaluator
  class PackageVerifierTest < Minitest::Test
    def test_returns_true_when_package_contains_required_files
      package = stub(spec: stub(files: %w[README.md LICENSE lib/runner.rb]))
      Gem::Package.expects(:new).with('agent_evaluator-0.0.1.gem').returns(package)

      assert PackageVerifier.call(
        package_path: 'agent_evaluator-0.0.1.gem',
        required_files: %w[README.md LICENSE]
      )
    end

    def test_raises_when_package_omits_required_files
      package = stub(spec: stub(files: ['README.md']))
      Gem::Package.expects(:new).with('agent_evaluator-0.0.1.gem').returns(package)

      error = assert_raises(PackageVerifier::Error) do
        PackageVerifier.call(
          package_path: 'agent_evaluator-0.0.1.gem',
          required_files: %w[README.md LICENSE]
        )
      end

      assert_equal 'Missing packaged files: LICENSE', error.message
    end
  end
end
