# frozen_string_literal: true

# frozen_string_literal: true:

load(File.expand_path('evaluator/version.rb', __dir__))
load(File.expand_path('config.rb', __dir__))
load(File.expand_path('client.rb', __dir__))
load(File.expand_path('context_hydrator.rb', __dir__))
load(File.expand_path('react_agent.rb', __dir__))
load(File.expand_path('evaluator/source_path_resolver.rb', __dir__))
load(File.expand_path('evaluator/package_verifier.rb', __dir__))
load(File.expand_path('evaluator/evaluate_command.rb', __dir__))
load(File.expand_path('evaluator/sandbox.rb', __dir__))
load(File.expand_path('evaluator/judge.rb', __dir__))
load(File.expand_path('evaluator/agent_runner.rb', __dir__))
load(File.expand_path('runner.rb', __dir__))

# Top-level namespace for the AgentEvaluator gem.
# Provides tools for comparing AI agent performance with and without skill context.
module Evaluator
end
