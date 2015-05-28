require 'pathname'
require 'error_to_communicate/format_terminal/heuristics/exception.rb'
require 'error_to_communicate/format_terminal/heuristics/no_method_error.rb'
require 'error_to_communicate/format_terminal/heuristics/wrong_number_of_arguments.rb'
require 'error_to_communicate/format_terminal/helpers'

module ErrorToCommunicate
  class FormatTerminal
    include FormatTerminal::Helpers

    def self.call(attributes)
      new(attributes).call
    end

    attr_accessor :info, :cwd, :theme, :heuristic_presenter

    def initialize(attributes)
      heuristic  = attributes.fetch :heuristic
      self.theme = attributes.fetch :theme
      self.cwd   = attributes.fetch :cwd
      self.info  = heuristic.exception_info
      self.heuristic_presenter = # for now
        case heuristic
        when ErrorToCommunicate::Heuristics::WrongNumberOfArguments
          Heuristics::WrongNumberOfArguments.new(heuristic, info, theme, cwd)
        when ErrorToCommunicate::Heuristics::NoMethodError
          Heuristics::NoMethodError.new(heuristic, info, theme, cwd)
        else
          Heuristics::Exception.new(heuristic, info, theme, cwd)
        end
    end

    def call
      display ||= [
        theme.separator_line,
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
