require "bundler/gem_tasks"
require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop)
Attestify::RakeTask.new(:test)
task default: %i[rubocop test]
