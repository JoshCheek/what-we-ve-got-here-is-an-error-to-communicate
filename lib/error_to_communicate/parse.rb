require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  # move this onto ExceptionInfo?
  module Parse

    # You could still get around this and blow up later,
    # but you'd probably have to craft an object to do it...
    # at which point, you should probably be allowed!
    def self.parseable?(exception)
      exception.respond_to?(:message) && exception.respond_to?(:backtrace)
    end

    def self.exception(exception)
      return exception if exception.kind_of? ExceptionInfo # already parsed
      ExceptionInfo.new \
        exception: exception,
        classname: exception.class.name,
        message:   exception.message,
        backtrace: backtrace(exception)
    end

    def self.backtrace(exception)
      # Really, there are better methods, e.g. backtrace_locations,
      # but they're unevenly implemented across versions and implementations
      locations = (exception.backtrace||[]).map &method(:backtrace_line)
      locations.each_cons(2) do |crnt, pred|
        crnt.pred = pred
        pred.succ = crnt
      end
      locations
    end

    # What if the line doesn't match for some reason?
    # Raise an exception?
    # Use some reasonable default? (is there one?)
    def self.backtrace_line(line)
      line =~ /^(.*?):(\d+):in `(.*?)'$/ # Are ^ and $ sufficient? Should be \A and (\Z or \z)?
      ExceptionInfo::Location.new(
        path:    $1,
        linenum: $2.to_i,
        label:   $3,
      )
    end
  end
end
