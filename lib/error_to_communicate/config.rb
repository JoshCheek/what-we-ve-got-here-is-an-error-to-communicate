require 'error_to_communicate/parse/registry'
require 'error_to_communicate/parse/exception'
require 'error_to_communicate/parse/argument_error'
require 'error_to_communicate/parse/no_method_error'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Config
    attr_accessor :registry

    def initialize
      self.registry = Parse::Registry.new(
        dont_parse: lambda { |exception|
          exception.kind_of? SystemExit
        },
        parsers: [
          Parse::ArgumentError,
          Parse::NoMethodError,
          Parse::Exception,
        ]
      )
    end

    def parse?(exception)
      registry.parse?(exception)
    end

    def parse(exception)
      registry.parse(exception)
    end
  end
end
