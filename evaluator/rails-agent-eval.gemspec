# frozen_string_literal: true

require_relative 'lib/evaluator/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-agent-eval'
  spec.version       = Evaluator::VERSION
  spec.authors       = ['Ismael Marin']
  spec.email         = ['ismael.marin@gmail.com']
  spec.summary       = 'The evaluation engine for Rails Agent Skills.'
  spec.homepage      = 'https://github.com/igmarin/rails-agent-eval'
  spec.description   = <<~DESC
    rails-agent-eval orchestrates side-by-side evaluation runs of an LLM coding agent
    (baseline vs. skill-hydrated) inside isolated git sandboxes, then scores the
    resulting diffs using an LLM judge.
  DESC
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.files         = Dir.chdir(__dir__) { Dir['lib/**/*.rb', 'bin/*', 'docs/**/*.md', 'README.md', 'LICENSE'] }
  spec.bindir        = 'bin'
  spec.executables   = ['evaluate']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'cgi',     '~> 0.5.1'
  spec.add_dependency 'dotenv',  '~> 3.2.0'
  spec.add_dependency 'faraday',  '~> 2.14'
  spec.add_dependency 'json',     '~> 2.19'
  spec.add_dependency 'parallel', '~> 1.26'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = 'https://github.com/igmarin/rails-agent-eval'
end
