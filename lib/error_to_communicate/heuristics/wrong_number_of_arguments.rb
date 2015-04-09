module WhatWeveGotHereIsAnErrorToCommunicate
  module Heuristics
    class WrongNumberOfArguments
      def self.for?(einfo)
        extract_from einfo
      end

      attr_accessor :exception_info
      attr_accessor :explanation
      attr_accessor :num_expected, :num_received

      def initialize(exception_info)
        self.exception_info = exception_info
        self.num_received, self.num_expected = self.class.extract_from(exception_info)
        self.explanation = 'Wrong number of arguments'
      end

      private

      def self.extract_from(einfo)
        case einfo.message
        when /^wrong number of arguments.*?\((\d+) for (\d+)\)$/ # MRI / JRuby
          num_received, num_expected = $1.to_i, $2.to_i
        when /^method '.*?': given (\d+).*? expected (\d+)$/ # RBX
          num_received, num_expected = $1.to_i, $2.to_i
        end
      end
    end
  end
end
