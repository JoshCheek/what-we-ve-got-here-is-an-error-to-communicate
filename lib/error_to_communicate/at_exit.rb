require 'interception'
require 'error_to_communicate'

seen = {}
recording_code = lambda { |exception, binding|
  seen = {exception: exception, binding: binding}
}

Interception.listen &recording_code

# Deal with global deps and console knowledge here
at_exit do
  Interception.unlisten recording_code
  exception = $!
  config    = ErrorToCommunicate::Config.default

  next unless config.accept? exception

  heuristic = config.heuristic_for exception
  heuristic.error_binding = seen[:binding] # uhm... :P

  formatted = config.format heuristic, Dir.pwd
  $stderr.puts formatted

  # There has got to be a better way to clear an exception,
  # this could break other at_exit hooks -.^
  read, write = IO.pipe
  $stderr = write
end
