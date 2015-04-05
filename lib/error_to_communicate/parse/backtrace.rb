require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    class Backtrace
      class Location
        def self.parse(backtrace_location)
          ExceptionInfo::Location.new(
            filepath:   backtrace_location.to_s[/^[^:]+/],
            linenum:    backtrace_location.to_s[/:(\d+):/,  1].to_i,
            methodname: backtrace_location.to_s[/`(.*?)'$/, 1],
          )
        end
      end

      def self.parse(options)
        locations = options.fetch(:backtrace_locations)
                           .map(&Location.method(:parse))

        locations.each_cons(2) do |crnt, succ|
          succ.pred = crnt
          crnt.succ = succ
        end

        locations
      end
    end
  end
end
