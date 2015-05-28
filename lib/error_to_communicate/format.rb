require 'pathname'
require 'error_to_communicate/format/heuristic_presenter'
require 'error_to_communicate/format/terminal_helpers'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    include Format::TerminalHelpers

    attr_accessor :info, :cwd, :theme, :heuristic_presenter

    def initialize(heuristic, theme, cwd)
      self.theme = theme
      self.info  = heuristic.exception_info
      self.cwd   = cwd
      self.heuristic_presenter = # for now
        case heuristic
        when Heuristics::WrongNumberOfArguments
          HeuristicPresenter::WrongNumberOfArguments.new(heuristic, info, theme, cwd)
        when Heuristics::NoMethodError
          HeuristicPresenter::NoMethodError.new(heuristic, info, theme, cwd)
        else
          HeuristicPresenter::Exception.new(heuristic, info, theme, cwd)
        end
    end

    def call
      display ||= begin
        [ theme.separator_line,
          *heuristic_presenter.header,

          theme.separator_line,
          *heuristic_presenter.helpful_info,

          theme.separator_line,
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
