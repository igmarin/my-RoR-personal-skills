# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/mcp_skills/skill_tool'

class SkillToolTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir('skill_tool_test')
    @base = Pathname.new(@tmpdir)

    skill_dir = @base.join('skills', 'test-category', 'code-review')
    skill_dir.mkpath
    skill_dir.join('SKILL.md').write('# Rails Code Review\nContent here.')

    write_tile_manifest(
      @base,
      {
        'code-review' => 'skills/test-category/code-review/SKILL.md',
        'empty-skill' => 'skills/test-category/empty-skill/SKILL.md'
      }
    )
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def test_call_returns_skill_content
    result = McpSkills::SkillTool.call(
      skill_name: 'code-review',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    content_text = result.content.first[:text]
    assert_includes content_text, 'Rails Code Review'
    assert_equal true, result.structured_content[:found]
    assert_equal 'code-review', result.structured_content[:name]
    assert_equal 'skills/test-category/code-review/SKILL.md', result.structured_content[:path]
    assert_equal 'test-category', result.structured_content[:category]
    assert_includes result.structured_content[:content], 'Rails Code Review'
  end

  def test_call_accepts_full_skill_md_path_from_list_skills
    result = McpSkills::SkillTool.call(
      skill_name: 'skills/test-category/code-review/SKILL.md',
      project_root: @base,
      server_context: {}
    )

    assert_instance_of MCP::Tool::Response, result
    assert_equal false, result.error?
    assert_equal true, result.structured_content[:found]
    assert_equal 'code-review', result.structured_content[:name]
  end

  def test_call_returns_error_response_for_unknown_skill
    result = McpSkills::SkillTool.call(
      skill_name: 'nonexistent-skill',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    assert result.error?, 'Expected an error response for unknown skill'
    assert_equal false, result.structured_content[:found]
    assert_match(/not found/, result.structured_content[:error])
  end

  def test_call_returns_error_response_for_missing_skill_md
    empty_skill = @base.join('skills', 'test-category', 'empty-skill')
    empty_skill.mkpath

    result = McpSkills::SkillTool.call(
      skill_name: 'empty-skill',
      project_root: @base,
      server_context: {}
    )
    assert_instance_of MCP::Tool::Response, result
    assert result.error?, 'Expected an error response when SKILL.md is absent'
  end

  def test_tool_has_description
    refute_nil McpSkills::SkillTool.description
    refute_empty McpSkills::SkillTool.description
  end

  def test_tool_input_schema_requires_skill_name
    schema = McpSkills::SkillTool.input_schema.to_h
    assert_includes schema[:required], 'skill_name'
  end

  def test_tool_output_schema_and_annotations_describe_read_only_structured_result
    tool_hash = McpSkills::SkillTool.to_h

    assert_equal 'Use Rails Skill', tool_hash[:title]
    assert_includes tool_hash[:outputSchema].fetch(:required), 'content'
    assert_equal true, tool_hash[:annotations].fetch(:readOnlyHint)
    assert_equal false, tool_hash[:annotations].fetch(:destructiveHint)
    assert_equal true, tool_hash[:annotations].fetch(:idempotentHint)
    assert_equal false, tool_hash[:annotations].fetch(:openWorldHint)
  end
end
