require 'error_to_communicate'

at_exit do
  exception = $!
  case exception
  when ArgumentError # really, this only works for wrong number of arguments
    $stderr.puts DispayErrors::ArgumentError.new(exception)
    exit! 1 # there has got to be a better way to clear an exception, this could break other at_exit hooks -.^
  end
end
