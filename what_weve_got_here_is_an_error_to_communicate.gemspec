require_relative 'lib/error_to_communicate/version'
Gem::Specification.new do |s|
  s.name        = 'what_weve_got_here_is_an_error_to_communicate'
  s.version     = ErrorToCommunicate::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Readable, helpful error messages"
  s.description = "Hooks into program lifecycle to display error messages to you in a helpufl way, with inlined code, colour, and helpful heuristics about what might be the cause."
  s.authors     = ["Josh Cheek", "Ben Voss"]
  s.email       = 'josh.cheek@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/JoshCheek/what-we-ve-got-here-is-an-error-to-communicate'

  s.add_runtime_dependency 'rouge', '~> 1.8'

  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'haiti', '< 0.3',  '>= 0.2.0'
  s.add_development_dependency 'pry',   '< 0.11', '>= 0.10.0'
  s.add_development_dependency 'rake',  '~> 10.4'
end
