module WhatWeveGotHereIsAnErrorToCommunicate
  class Parse
    DEFAULT_REGISTRY = new

    def <<(parser)
      parsers << parser
      self
    end

    def parse?(exception)
      parsers.any? { |parser| parser.parse? exception }
    end

    def parse(exception)
      parser = parsers.find { |parser| parser.parse? exception }
      return parser.parse exception if parser
      raise "NO PARSER FOUND FOR #{exception.inspect}"
    end

    private

    def parsers
      @parsers ||= []
    end
  end

  def self.parse?(exception, options={})
    options.fetch(:parser, Parse::DEFAULT_REGISTRY).parse?(exception)
  end

  def self.parse(exception, options={})
    options.fetch(:parser, Parse::DEFAULT_REGISTRY).parse(exception)
  end

  require 'error_to_communicate/parse/argument_error'
  Parse::DEFAULT_REGISTRY << Parse::ArgumentError

  require 'error_to_communicate/parse/no_method_error'
  Parse::DEFAULT_REGISTRY << Parse::NoMethodError
end
