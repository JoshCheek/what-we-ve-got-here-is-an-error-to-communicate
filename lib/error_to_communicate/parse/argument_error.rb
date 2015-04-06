require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module ArgumentError
      def self.parse?(exception)
        exception.kind_of? ::ArgumentError
      end

      def self.parse(exception)
        ExceptionInfo::ArgumentError.new(
          exception:    exception,
          classname:    exception.class.to_s,
          explanation:  'Wrong number of arguments',
          backtrace:    Backtrace.parse(exception),
          num_expected: exception.message.scan(/\d+/)[-1].to_i,
          num_received: exception.message.scan(/\d+/)[-2].to_i,
        )
      end
    end
  end
end
