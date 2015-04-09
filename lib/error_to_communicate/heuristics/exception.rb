module WhatWeveGotHereIsAnErrorToCommunicate
  module Heuristics
    class Exception
      def self.for?(einfo)
        true
      end

      attr_accessor :exception_info

      def initialize(exception_info)
        self.exception_info = exception_info
      end

      def explanation
        exception_info.message
      end
    end
  end
end
