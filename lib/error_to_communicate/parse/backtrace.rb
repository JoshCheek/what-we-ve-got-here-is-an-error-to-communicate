require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    module Backtrace
      def self.parse_locations(backtrace_locations)
        locations = backtrace_locations.map(&method(:parse_location))
        locations.each_cons(2) do |crnt, succ|
          succ.pred = crnt
          crnt.succ = succ
        end
        locations
      end

      def self.parse_location(backtrace_location)
        ExceptionInfo::Location.new(
          filepath:   backtrace_location.to_s[/^[^:]+/],
          linenum:    backtrace_location.to_s[/:(\d+):/,  1].to_i,
          methodname: backtrace_location.to_s[/`(.*?)'$/, 1],
        )
      end
    end
  end
end
