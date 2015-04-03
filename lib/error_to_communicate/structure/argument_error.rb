module WhatWeveGotHereIsAnErrorToCommunicate
  module Structure
    class ArgumentError
      attr_accessor :classname,
                    :explanation,
                    :num_expected,
                    :num_received,
                    :backtrace

      def initialize(attributes)
        self.classname    = attributes.fetch :classname
        self.explanation  = attributes.fetch :explanation
        self.num_expected = attributes.fetch :num_expected
        self.num_received = attributes.fetch :num_received
        self.backtrace    = attributes.fetch :backtrace
      end
    end
  end
end
