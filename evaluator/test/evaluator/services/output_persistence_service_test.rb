# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

module Evaluator
  module Services
    class OutputPersistenceServiceTest < Minitest::Test
      def setup
        @temp_dir = Dir.mktmpdir
        @result = {
          success: true,
          tasks: [{ path: 'test/path', score: 85 }],
          source_path: 'test/source'
        }
      end

      def teardown
        FileUtils.rm_rf(@temp_dir)
      end

      def test_call_with_valid_output_path
        output_path = File.join(@temp_dir, 'output.json')

        result = OutputPersistenceService.call(@result, output_path: output_path)

        assert result[:success]
        assert_path_exists output_path

        content = JSON.parse(File.read(output_path))

        assert content['success']
        assert_equal 1, content['tasks'].length
      end

      def test_call_with_nil_output_path
        result = OutputPersistenceService.call(@result, output_path: nil)

        assert result[:success]
        assert_nil result[:response][:message]
      end

      def test_call_with_empty_output_path
        result = OutputPersistenceService.call(@result, output_path: '')

        assert result[:success]
        assert_nil result[:response][:message]
      end

      def test_call_creates_parent_directories
        output_path = File.join(@temp_dir, 'nested', 'dir', 'output.json')

        result = OutputPersistenceService.call(@result, output_path: output_path)

        assert result[:success]
        assert_path_exists output_path
      end

      def test_call_with_write_permission_error
        output_path = '/root/cannot_write_here.json'

        result = OutputPersistenceService.call(@result, output_path: output_path)

        refute result[:success]
        assert_includes result[:response][:error][:message], 'Failed to write output file'
      end

      def test_call_with_complex_result_data
        complex_result = {
          success: true,
          tasks: [
            { path: 'task1', judge_score: { baseline_score: 80, context_score: 90 } },
            { path: 'task2', judge_score: { baseline_score: 70, context_score: 85 } }
          ],
          source_path: 'complex/source',
          metadata: { model: 'test-model', version: '1.0' }
        }
        output_path = File.join(@temp_dir, 'complex.json')

        result = OutputPersistenceService.call(complex_result, output_path: output_path)

        assert result[:success]
        content = JSON.parse(File.read(output_path))

        assert_equal 2, content['tasks'].length
        assert_equal 'test-model', content['metadata']['model']
      end

      def test_call_overwrites_existing_file
        output_path = File.join(@temp_dir, 'existing.json')
        File.write(output_path, '{"old": "data"}')

        result = OutputPersistenceService.call(@result, output_path: output_path)

        assert result[:success]
        content = JSON.parse(File.read(output_path))

        assert content['success']
        refute_includes content.keys, 'old'
      end
    end
  end
end
