require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--format', ENV['RUBOCOP_FORMAT']] if ENV['RUBOCOP_FORMAT']
end

RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]
