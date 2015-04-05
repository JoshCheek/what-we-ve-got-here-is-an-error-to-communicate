require 'error_to_communicate/exception_info'
require 'error_to_communicate/parse/backtrace'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    module NoMethodError
      def self.parse?(exception)
        exception.kind_of? ::NoMethodError
      end

      def self.parse(exception)
        ExceptionInfo::NoMethodError.new(
          classname:             'NoMethodError',
          explanation:           exception.message[/^[^\(]*/].strip,
          backtrace:             Backtrace.parse_locations(exception.backtrace_locations),
          undefined_method_name: exception.message.split(/\W+/)[2],
        )
      end
    end
  end
end
