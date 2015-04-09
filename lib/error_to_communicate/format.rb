require 'pathname'
require 'error_to_communicate/format/heuristic_presenter'
require 'error_to_communicate/format/terminal_helpers'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    include Format::TerminalHelpers

    attr_accessor :info, :cwd, :heuristic_presenter

    def initialize(heuristic, cwd)
      self.info      = heuristic.exception_info
      self.cwd       = cwd
      self.heuristic_presenter = # for now
        case heuristic
        when Heuristics::WrongNumberOfArguments
          HeuristicPresenter::WrongNumberOfArguments.new(heuristic, info, cwd)
        when Heuristics::NoMethodError
          HeuristicPresenter::NoMethodError.new(heuristic, info, cwd)
        else
          HeuristicPresenter::Exception.new(heuristic, info, cwd)
        end
    end

    def call
      display ||= begin
        [ separator_line,
          *heuristic_presenter.header,

          separator_line,
          *heuristic_presenter.helpful_info,

          separator_line,
          *info.backtrace.map { |location|
            display_location location:   location,
                             highlight:  (location.pred && location.pred.label),
                             context:    0..0,
                             emphasisis: :path,
                             cwd:        cwd
          }
        ].join("")
      end
    end
  end
end
