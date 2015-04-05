require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module Exception
      def self.parse?(exception)
        exception.respond_to?(:message) && Backtrace.parse?(exception)
      end

      def self.parse(exception)
        ExceptionInfo.new(
          exception:   exception,
          classname:   exception.class.to_s,
          explanation: exception.message,
          backtrace:   Backtrace.parse(exception),
        )
      end
    end
  end
end
