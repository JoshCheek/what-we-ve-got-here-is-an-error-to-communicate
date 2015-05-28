require 'pathname'
require 'error_to_communicate/format_terminal/helpers'

module ErrorToCommunicate
  class FormatTerminal

    def self.call(attributes)
      new(attributes).call
    end

    attr_accessor :info, :cwd, :theme, :heuristic_presenter

    def initialize(attributes)
      extend ErrorToCommunicate::FormatTerminal::Helpers
      self.theme               = attributes.fetch :theme
      self.cwd                 = attributes.fetch :cwd
      self.info                = attributes.fetch :einfo
      self.heuristic_presenter = attributes.fetch :heuristic_formatter
    end

    def call
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
