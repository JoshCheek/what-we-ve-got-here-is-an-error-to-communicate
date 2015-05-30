#!/usr/bin/env rake
task :default => :spec

desc 'Run all tests'
task(:spec) { sh 'rspec' }
namespace :spec do
  desc 'Test configuration'
  task(:config)          { sh 'rspec --tag config' }

  desc 'Test the heuristcs'
  task(:heuristic)       { sh 'rspec --tag heuristic' }

  desc 'Test exception info'
  task(:einfo)           { sh 'rspec --tag einfo' }

  desc 'Test the RSpec formatter'
  task(:rspec_formatter) { sh 'rspec --tag rspec_formatter' }

  desc 'Run acceptance tests (expensive)'
  task(:acceptance)      { sh 'rspec --tag acceptance' }
end
