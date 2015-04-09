require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  # move this onto ExceptionInfo?
  module Parse
    def self.exception(exception)
      ExceptionInfo.new \
        exception: exception,
        classname: exception.class.name,
        message:   exception.message,
        backtrace: backtrace(exception)
    end

    def self.backtrace(exception)
      # Really, there are better methods, e.g. backtrace_locations,
      # but they're unevenly implemented across versions and implementations
      locations = exception.backtrace.map &method(:backtrace_line)
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
