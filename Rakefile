#!/usr/bin/env rake
task :default => :spec

desc 'Run all tests'
task(:spec) { sh 'rspec' }

namespace :spec do
  def self.spec(name, tags, description)
    desc description
    task(name) { sh "rspec --tag #{tags}" }
  end
  spec :config,     'config',          'Test configuration'
  spec :heuristic,  'heuristic',       'Test the heuristcs'
  spec :einfo,      'einfo',           'Test exception info'
  spec :formatters, 'rspec_formatter', 'Test the RSpec formatter'
  spec :acceptance, 'acceptance',      'Run acceptance tests (expensive)'
  spec :quick,      '~acceptance',     'Run all specs except the acceptance tests (b/c they\'re slow)'
end
