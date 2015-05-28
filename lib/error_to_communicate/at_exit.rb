require 'error_to_communicate'

module WhatWeveGotHereIsAnErrorToCommunicate
  at_exit do
    exception = $!
    config    = Config.default
    next unless config.accept? exception
    heuristic = config.heuristic_for exception
    formatted = config.format heuristic, Dir.pwd
    $stderr.puts formatted
    exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
  end
end
