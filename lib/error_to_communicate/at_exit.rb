require 'error_to_communicate/parse'
require 'error_to_communicate/format'

module WhatWeveGotHereIsAnErrorToCommunicate
  at_exit do
    exception = $!
    next unless parse? exception
    $stderr.puts format parse exception
    exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
  end
end
