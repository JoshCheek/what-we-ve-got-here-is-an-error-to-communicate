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

      # Definitely not sufficient, but I'll wait until I have better examples of how it fucks up.
      def self.parse_backtrace_line(line)
        filepath, linenum, label, * = line.split(":")
        label = label[/`(.*?)'/, 1]
        ExceptionInfo::Location.new(
          filepath:   filepath,
          linenum:    linenum.to_i,
          methodname: label,
        )
      end
    end
  end
end
