require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
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
          filepath:   backtrace_location.absolute_path,
          linenum:    backtrace_location.lineno,
          methodname: backtrace_location.base_label,
        )
      end
    end
  end
end
