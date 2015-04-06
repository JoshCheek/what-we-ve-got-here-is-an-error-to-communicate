require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module Backtrace
      def self.parse?(exception)
        # Really, there are better methods, e.g. backtrace_locations,
        # but they're unevenly implemented across versions and implementations
        exception.respond_to? :backtrace
      end

      def self.parse(exception)
        locations = exception.backtrace.map &method(:parse_backtrace_line)
        locations.each_cons(2) do |crnt, succ|
          succ.pred = crnt
          crnt.succ = succ
        end
        locations
      end

      # TODO: What if the line doesn't match for some reason?
      # Raise an exception?
      # Use some reasonable default? (is there one?)
      def self.parse_backtrace_line(line)
        line =~ /^(.*?):(\d+):in `(.*?)'$/ # Are ^ and $ sufficient? Should be \A and (\Z or \z)?
        ExceptionInfo::Location.new(
          filepath:   $1,
          linenum:    $2.to_i,
          methodname: $3,
        )
      end
    end
  end
end
