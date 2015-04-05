module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    DEFAULT = new

    def <<(parser)
      parsers << parser
      self
    end

    def parse(options)
      exception = options.fetch :exception
      parser    = parsers.find { |parser| parser.parse? exception }
      return parser.parse exception if parser
      raise "NO PARSER FOUND FOR #{exception.inspect}"
    end

    private

    def parsers
      @parsers ||= []
    end
  end

  def self.parse(attributes)
    attributes.fetch(:parser, Parse::DEFAULT)
              .parse(exception: attributes.fetch(:exception))
  end

  require 'error_to_communicate/parse/argument_error'
  Parse::DEFAULT << Parse::ArgumentError

  require 'error_to_communicate/parse/no_method_error'
  Parse::DEFAULT << Parse::NoMethodError
end
