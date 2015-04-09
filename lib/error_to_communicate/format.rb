require 'pathname'
require 'error_to_communicate/format/heuristic'
require 'error_to_communicate/format/terminal_helpers'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    def self.call(exception_info, cwd)
      new(exception_info, cwd).call
    end

    include Format::TerminalHelpers

    attr_accessor :info, :cwd, :heuristic

    def initialize(exception_info, cwd)
      self.info      = exception_info
      self.cwd       = cwd
      self.heuristic = Heuristic.for(exception_info, cwd)
    end

    def call
      display ||= begin
        [ separator_line,
          *heuristic.header,

          separator_line,
          *heuristic.helpful_info,

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
