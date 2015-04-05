require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    class NoMethodError
      def self.parse?(exception)
        exception.kind_of? ::NoMethodError
      end

      def self.parse(exception)
        new(exception).call
      end

      def initialize(exception)
        @exception = exception
      end

      def call
        @parsed ||= ExceptionInfo.new(
          classname:              'NoMethodError',
          explanation:            @exception.message[/^[^\(]*/].strip,
          undefined_method_name:  @exception.message.split(/\W+/)[2],
          backtrace:              Backtrace.parse(backtrace_locations: @exception.backtrace_locations),
        )
      end
    end
  end
end
