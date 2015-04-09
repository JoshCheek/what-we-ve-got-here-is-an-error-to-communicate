require 'error_to_communicate'

module WhatWeveGotHereIsAnErrorToCommunicate
  at_exit do
    exception = $!
    next unless CONFIG.accept? exception
    heuristic = CONFIG.heuristic_for exception
    formatted = CONFIG.format(heuristic, Dir.pwd)
    $stderr.puts formatted
    exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
  end
end
