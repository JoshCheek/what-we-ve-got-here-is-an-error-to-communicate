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

    DEFAULT_DONT_PARSE = lambda do |exception|
      !exception.kind_of?(Exception) ||
        exception.kind_of?(SystemExit)
    end

    def self.default
      new heuristics: DEFAULT_HEURISTICS,
          dont_parse: DEFAULT_DONT_PARSE
    end

    attr_accessor :heuristics, :dont_parse

    def initialize(heuristics:, dont_parse:)
      self.heuristics   = heuristics
      self.dont_parse = dont_parse
    end

    def accept?(exception)
      !dont_parse.call(exception)
    end

    def heuristic_for(exception)
      einfo = Parse.exception(exception)
      heuristics.find { |heuristic| heuristic.for? einfo }
                .new(einfo)
    end

    def format(heuristic, cwd)
      Format.new(heuristic, cwd).call
    end
  end
end
