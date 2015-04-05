module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    class Registry
      def initialize(parsers=[])
        @parsers = parsers
      end

      def <<(parser)
        @parsers << parser
        self
      end

      def parser_for(exception)
        @parsers.find { |parser| parser.parse? exception }
      end

      def parse?(exception)
        !!parser_for(exception)
      end

      def parse(exception)
        parser = @parsers.find { |parser| parser.parse? exception }
        return parser.parse exception if parser
        raise ::ArgumentError.new, "No parser found for #{exception.inspect}"
      end
    end
  end
end
