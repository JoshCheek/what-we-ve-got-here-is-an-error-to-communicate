module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    class Registry
      def initialize
        @parsers ||= []
      end

      def <<(parser)
        @parsers << parser
        self
      end

      def parse?(exception)
        @parsers.any? { |parser| parser.parse? exception }
      end

      def parse(exception)
        parser = @parsers.find { |parser| parser.parse? exception }
        return parser.parse exception if parser
        raise "NO PARSER FOUND FOR #{exception.inspect}"
      end
    end
  end
end
