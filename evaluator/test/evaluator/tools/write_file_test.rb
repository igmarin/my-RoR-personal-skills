# frozen_string_literal: true

require 'test_helper'

module Evaluator
  module Tools
    # Tests for Evaluator::Tools::WriteFile
    class WriteFileTest < Minitest::Test
      def test_call_writes_to_file
        Dir.mktmpdir do |dir|
          working_dir = Pathname.new(dir).expand_path

          result = WriteFile.call('new_file.txt', 'New text', working_dir)

          assert_equal 'Successfully wrote to new_file.txt', result
          assert_equal 'New text', File.read(File.join(dir, 'new_file.txt'))
        end
      end
    end
  end
end
