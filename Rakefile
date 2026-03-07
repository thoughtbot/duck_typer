# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rspec/core/rake_task"

Rake::TestTask.new(:minitest) do |t|
  t.pattern = "test/**/*_test.rb"
end

RSpec::Core::RakeTask.new(:rspec)

task test: %i[minitest rspec]

task default: %i[]
