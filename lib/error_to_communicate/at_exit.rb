require 'error_to_communicate'
require 'error_to_communicate/format'

module WhatWeveGotHereIsAnErrorToCommunicate
  at_exit do
    exception = $!
    next unless CONFIG.parse? exception
    formatted = format CONFIG.parse(exception), Dir.pwd
    $stderr.puts formatted
    exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
  end
end
