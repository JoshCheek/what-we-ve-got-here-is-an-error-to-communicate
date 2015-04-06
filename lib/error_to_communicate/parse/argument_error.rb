require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module ArgumentError
      def self.parse?(exception)
        exception.kind_of? ::ArgumentError
      end

      def self.parse(exception)
        case exception.message
        when /(\d+) for (\d+)/
          num_received, num_expected = $1.to_i, $2.to_i
        when /given (\d+).*? expected (\d+)/
          num_received, num_expected = $1.to_i, $2.to_i
        end
        ExceptionInfo::ArgumentError.new(
          exception:    exception,
          classname:    exception.class.to_s,
          explanation:  'Wrong number of arguments',
          backtrace:    Backtrace.parse(exception),
          num_expected: num_expected,
          num_received: num_received,
        )
      end
    end
  end
end
