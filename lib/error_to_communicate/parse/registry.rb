module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    class Registry
      def initialize(options)
        @dont_parse = options.fetch :dont_parse
        @parsers    = options.fetch :parsers
      end

      def <<(parser)
        @parsers << parser
        self
      end

      def parser_for(exception)
        return nil if @dont_parse.call exception
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
