# frozen_string_literal: true

require_relative 'lib/evaluator/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-agent-evaluator'
  spec.version       = Evaluator::VERSION
  spec.authors       = ['Ismael Marin']
  spec.email         = ['ismael.marin@gmail.com']
  spec.summary       = 'Compare LLM agent performance with and without skill context.'
  spec.description   = <<~DESC
    AgentEvaluator orchestrates side-by-side evaluation runs of an LLM coding agent
    (baseline vs. skill-hydrated) inside isolated git sandboxes, then scores the
    resulting diffs using an LLM judge.
  DESC
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.files         = Dir['lib/**/*.rb', 'bin/*', 'README.md', 'LICENSE']
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
end
