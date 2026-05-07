# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'

REPO_ROOT = Pathname.new(__dir__).join('..', '..').realpath

def build_fixture_tree(base_dir)
  base = Pathname.new(base_dir)

  {
    'skills/code-quality' => ['rails-code-review'],
    'skills/testing' => ['rails-tdd-slices'],
    'skills/patterns' => ['ruby-service-objects']
  }.each do |parent, skills|
    skills.each do |skill|
      dir = base.join(parent, skill)
      dir.mkpath
      dir.join('SKILL.md').write("# #{skill}\nSkill content for #{skill}.")
      dir.join('EXAMPLES.md').write("# Examples for #{skill}")
    end
  end

  build_dir = base.join('build')
  build_dir.mkpath
  build_dir.join('SKILL.md').write("# build\nBuild skill content.")

  base.join('skill-template').mkpath
  base.join('skill-template').join('SKILL.md').write('# Template')

  docs_dir = base.join('docs')
  docs_dir.mkpath
  docs_dir.join('workflow-guide.md').write('# Workflow Guide')
  docs_dir.join('overview.md').write('# Overview')
  docs_dir.join('workflows').mkpath
  docs_dir.join('workflows', 'discovery.md').write('# Discovery Docs')

  workflows_dir = base.join('workflows', 'rails-review-flow')
  workflows_dir.mkpath
  workflows_dir.join('SKILL.md').write('# rails-review-flow')
  workflows_dir.join('EXAMPLES.md').write('# Workflow examples')

  tessl_dir = base.join('.tessl', 'tiles', 'owner', 'repo', 'rails-code-review')
  tessl_dir.mkpath
  tessl_dir.join('SKILL.md').write('# Duplicate tessl skill')
end
