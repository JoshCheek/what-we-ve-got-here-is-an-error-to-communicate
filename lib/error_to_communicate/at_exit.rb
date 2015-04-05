require 'error_to_communicate/parse'
require 'error_to_communicate/format'

module WhatWeveGotHereIsAnErrorToCommunicate
  at_exit do
    exception = $!
    case exception
    when ::ArgumentError
      ex = parse exception: exception
      $stderr.puts format exception: ex
      exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
    when ::NoMethodError
      ex = parse exception: exception
      $stderr.puts format exception: ex
      exit! 1
    end
  end
end
