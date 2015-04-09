module WhatWeveGotHereIsAnErrorToCommunicate
  module Heuristics
    class NoMethodError
      def self.for?(exception)
        exception.kind_of? ::NoMethodError
      end

      attr_accessor :exception_info

      def initialize(exception_info)
        self.exception_info = exception_info
      end

      def explanation
        exception_info.message[/^[^\(]*/].strip
      end

      def undefined_method_name
        words = exception_info.message.split(/\s+/)
        words[2][1...-1]
      end
    end
  end
end
