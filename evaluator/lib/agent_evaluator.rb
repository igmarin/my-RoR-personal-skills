# frozen_string_literal: true

require_relative 'evaluator/version'
require_relative 'config'
require_relative 'client'
require_relative 'context_hydrator'
require_relative 'react_agent'
require_relative 'evaluator/source_path_resolver'
require_relative 'evaluator/evaluate_command'
require_relative 'evaluator/sandbox'
require_relative 'evaluator/judge'
require_relative 'evaluator/agent_runner'
require_relative 'runner'

# Top-level namespace for the AgentEvaluator gem.
# Provides tools for comparing AI agent performance with and without skill context.
module Evaluator
end
