# frozen_string_literal: true

require_relative 'lib/agent_evaluator'

require 'rake/testtask'
require 'reek/rake/task'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new(:rubocop)

Reek::Rake::Task.new(:reek) do |t|
  t.config_file = '.reek.yml'
  t.source_files = 'lib'
end

namespace :package do
  desc 'Build the evaluator gem'
  task :build do
    sh 'gem build agent_evaluator.gemspec'
  end

  desc 'Verify the evaluator gem contains required release files'
  task verify: :build do
    gem_path = FileList['agent_evaluator-*.gem'].max_by { |path| File.mtime(path) }
    abort('No built evaluator gem found') unless gem_path

    result = Evaluator::PackageVerifier.call(package_path: gem_path)
    abort(result[:response][:error][:message]) unless result[:success]
  end
end

task default: %i[rubocop reek test]
