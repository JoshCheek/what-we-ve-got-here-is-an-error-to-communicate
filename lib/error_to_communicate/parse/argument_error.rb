require 'error_to_communicate/parse/backtrace'
require 'error_to_communicate/structure/argument_error'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    class ArgumentError
      def self.parse?(exception)
        exception.kind_of? ::ArgumentError
      end

      def self.parse(exception)
        new(exception).call
      end

      def initialize(exception)
        @exception = exception
      end

      def call
        @parsed ||= Structure::ArgumentError.new(
          classname:    'ArgumentError',
          explanation:  @exception.message[/^[^\(]*/].strip,
          num_expected: @exception.message.scan(/\d+/)[1].to_i,
          num_received: @exception.message.scan(/\d+/)[0].to_i,
          backtrace:    Backtrace.parse(backtrace_locations: @exception.backtrace_locations),
        )
      end
    end
  end
end
