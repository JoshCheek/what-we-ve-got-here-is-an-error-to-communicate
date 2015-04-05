require 'error_to_communicate/parse/registry'
require 'error_to_communicate/parse/argument_error'
require 'error_to_communicate/parse/no_method_error'

module WhatWeveGotHereIsAnErrorToCommunicate
  extend self

  def parse?(exception, options={})
    options.fetch(:parser, Parse::DEFAULT_REGISTRY).parse?(exception)
  end

  def parse(exception, options={})
    options.fetch(:parser, Parse::DEFAULT_REGISTRY).parse(exception)
  end

  Parse::DEFAULT_REGISTRY = Parse::Registry.new [
    Parse::ArgumentError,
    Parse::NoMethodError,
  ]
end
