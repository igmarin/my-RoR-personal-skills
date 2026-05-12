# frozen_string_literal: true

require 'json'
require_relative 'test_helper'

class DistributionContractTest < Minitest::Test
  def test_registry_metadata_matches_runtime_contract
    registry = JSON.parse(REPO_ROOT.join('mcp_server', 'registry.json').read)

    assert_equal %w[list_skills use_skill], registry.fetch('tools').map { |tool| tool.fetch('name') }
    assert_equal %w[doc/* workflow/*], registry.fetch('resources').map { |resource| resource.fetch('prefix') }
  end

  def test_root_readme_describes_use_skill_instead_of_skill_resources
    readme = REPO_ROOT.join('README.md').read

    assert_includes readme, 'The `use_skill` tool'
    refute_includes readme, '| `skill/<name>`'
  end

  def test_implementation_guide_points_to_canonical_mcp_setup_and_docker_fallback
    guide = REPO_ROOT.join('docs', 'implementation-guide.md').read

    assert_includes guide, '[mcp_server/README.md](../mcp_server/README.md)'
    assert_includes guide, 'Docker fallback'
  end

  def test_mcp_server_readme_describes_root_dockerfile_layout
    readme = REPO_ROOT.join('mcp_server', 'README.md').read

    assert_includes readme, '../Dockerfile'
    refute_includes readme, '├── Dockerfile'
  end
end
