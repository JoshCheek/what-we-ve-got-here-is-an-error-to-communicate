require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module NoMethodError
      def self.parse?(exception)
        exception.kind_of? ::NoMethodError
      end

      def self.parse(exception)
        ExceptionInfo::NoMethodError.new(
          exception:             exception,
          classname:             exception.class.to_s,
          explanation:           exception.message[/^[^\(]*/].strip,
          backtrace:             Backtrace.parse(exception),
          undefined_method_name: extract_method_name(exception.message),
        )
      end

      def self.extract_method_name(message)
        words = message.split(/\s+/)
        words[2][1...-1]
      end
    end
  end
end
