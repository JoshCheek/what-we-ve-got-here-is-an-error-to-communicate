require 'error_to_communicate/version'
require 'error_to_communicate/format'
require 'error_to_communicate/exception_info'
require 'error_to_communicate/theme'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Config
    # Extract into a config_default.rb?
    # this would allow you to load the config code without loading all of the lib,
    # which could get expensive as more heuristics are created.
    require 'error_to_communicate/heuristics/exception'
    require 'error_to_communicate/heuristics/no_method_error'
    require 'error_to_communicate/heuristics/wrong_number_of_arguments'
    DEFAULT_HEURISTICS = [
      Heuristics::WrongNumberOfArguments,
      Heuristics::NoMethodError,
      Heuristics::Exception,
    ]

    DEFAULT_BLACKLIST = lambda do |einfo|
      einfo.classname == 'SystemExit'
    end

    def self.new_default
      new heuristics: DEFAULT_HEURISTICS,
          blacklist:  DEFAULT_BLACKLIST,
          theme:      Theme.new # this is still really fkn rough
    end

    def self.default
      @default ||= new_default
    end

    attr_accessor :heuristics, :blacklist, :theme

    def initialize(attributes)
      self.heuristics = attributes.fetch :heuristics
      self.blacklist  = attributes.fetch :blacklist
      self.theme      = attributes.fetch :theme, Theme.new
    end

    def accept?(exception)
      return false unless ExceptionInfo.parseable? exception
      einfo = ExceptionInfo.parse(exception)
      !blacklist.call(einfo) && !!heuristics.find { |h| h.for? einfo }
    end

    def heuristic_for(exception)
      accept?(exception) ||
        raise(ArgumentError, "Asked for a heuristic on an object we don't accept: #{exception.inspect}")
      einfo = ExceptionInfo.parse(exception)
      heuristics.find { |heuristic| heuristic.for? einfo }.new(einfo)
    end

    def format(heuristic, cwd)
      Format.new(heuristic, theme, cwd).call
    end
  end
end
