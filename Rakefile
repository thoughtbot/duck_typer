# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rspec/core/rake_task"
require "standard/rake"

Rake::TestTask.new(:minitest) do |t|
  t.pattern = "test/**/*_test.rb"
end

RSpec::Core::RakeTask.new(:rspec)

task :check_lockfile do
  sh "bundle install --quiet"

  unless `git diff Gemfile.lock`.empty?
    abort "Gemfile.lock is out of date. Commit the updated lockfile."
  end
end

task test: %i[minitest rspec]
task ci: %i[check_lockfile standard test]

task default: %i[]
