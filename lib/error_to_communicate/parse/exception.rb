require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module Exception
      # ...uhm, really, it can parse a SystemExit
      # it's only our current context where this doesn't make sense :/
      def self.parse?(exception)
        exception.kind_of?(::Exception) && !exception.kind_of?(::SystemExit)
      end

      def self.parse(exception)
        ExceptionInfo.new(
          exception:   exception,
          classname:   exception.class.to_s,
          explanation: exception.message,
          backtrace:   Backtrace.parse_locations(exception.backtrace_locations),
        )
      end
    end
  end
end
