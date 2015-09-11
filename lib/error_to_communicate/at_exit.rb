require 'interception'
require 'error_to_communicate'

error_binding  = nil
recording_code = lambda { |_exc, binding|
  error_binding = binding
}

Interception.listen &recording_code

# Deal with global deps and console knowledge here
at_exit do
  Interception.unlisten recording_code
  exception = $!
  config    = ErrorToCommunicate::Config.default

  next unless config.accept? exception, error_binding

  heuristic = config.heuristic_for exception, error_binding

  formatted = config.format heuristic, Dir.pwd
  $stderr.puts formatted

  # There has got to be a better way to clear an exception,
  # this could break other at_exit hooks -.^
  read, write = IO.pipe
  $stderr = write
end
