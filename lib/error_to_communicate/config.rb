require 'error_to_communicate/version'
require 'error_to_communicate/parse'
require 'error_to_communicate/format'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Config
    require 'error_to_communicate/heuristics/exception'
    require 'error_to_communicate/heuristics/no_method_error'
    require 'error_to_communicate/heuristics/wrong_number_of_arguments'
    DEFAULT_HEURISTICS = [
      Heuristics::WrongNumberOfArguments,
      Heuristics::NoMethodError,
      Heuristics::Exception,
    ]

    # TODO: These are backwards!
    DEFAULT_DONT_PARSE = lambda do |einfo|
      einfo.classname == 'SystemExit'
    end

    def self.new_default
      new heuristics: DEFAULT_HEURISTICS,
          dont_parse: DEFAULT_DONT_PARSE
    end

    def self.default
      @default ||= new_default
    end

    attr_accessor :heuristics, :dont_parse

    def initialize(attributes)
      self.heuristics = attributes.fetch :heuristics
      self.dont_parse = attributes.fetch :dont_parse
    end

    def accept?(exception)
      return false unless Parse.parseable? exception
      einfo = Parse.exception(exception)
      !dont_parse.call(einfo) && !!heuristics.find { |h| h.for? einfo }
    end

    def heuristic_for(exception)
      accept?(exception) ||
        raise(ArgumentError, "Asked for a heuristic on an object we don't accept: #{exception.inspect}")
      einfo = Parse.exception(exception)
      heuristics.find { |heuristic| heuristic.for? einfo }.new(einfo)
    end

    def format(heuristic, cwd)
      Format.new(heuristic, cwd).call
    end
  end
end
