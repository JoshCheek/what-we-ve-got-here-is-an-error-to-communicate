require 'error_to_communicate'

# Deal with global deps and console knowledge here
at_exit do
  exception = $!
  config    = ErrorToCommunicate::Config.default

  next unless config.accept? exception

  heuristic = config.heuristic_for exception
  formatted = config.format heuristic, Dir.pwd
  $stderr.puts formatted

  # There has got to be a better way to clear an exception,
  # this could break other at_exit hooks -.^
  exit! 1
end
