# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for Evaluator::Tools::Base
    class BaseTest < Minitest::Test
      # Expose protected method for testing
      class TestBase < Base
        def self.public_secure_path(path, working_dir_path)
          secure_path(path, working_dir_path)
        end
      end

      def test_secure_path_resolves_valid_path
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path
          result = TestBase.public_secure_path('test.txt', working_dir)

          assert_equal working_dir.realpath.join('test.txt'), result
        end
      end

      def test_secure_path_prevents_traversal
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path

          error = assert_raises(RuntimeError) do
            TestBase.public_secure_path('../test.txt', working_dir)
          end

          assert_match(/Path traversal is not allowed/, error.message)
        end
      end
    end
  end
end
