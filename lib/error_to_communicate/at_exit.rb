require 'error_to_communicate'
require 'error_to_communicate/format'

module WhatWeveGotHereIsAnErrorToCommunicate
  at_exit do
    exception = $!
    next unless CONFIG.parse? exception
    exception_info = CONFIG.parse exception
    $stderr.puts Format.call(exception_info, Dir.pwd)
    exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
  end
end
