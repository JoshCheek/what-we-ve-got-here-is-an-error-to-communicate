require 'pathname'

module ErrorToCommunicate
  class FormatTerminal

    def self.call(attributes)
      new(attributes).call
    end

    attr_accessor :info, :cwd, :theme, :heuristic_presenter, :presenter

    def initialize(attributes)
      self.theme               = attributes.fetch :theme
      self.cwd                 = attributes.fetch :cwd
      self.info                = attributes.fetch :einfo
      self.heuristic_presenter = attributes.fetch :heuristic_formatter
      self.presenter           = attributes.fetch :presenter
    end

    def call
      [ theme.separator_line,
        *heuristic_presenter.header,

        theme.separator_line,
        *heuristic_presenter.helpful_info,

        theme.separator_line,
        *info.backtrace.map { |location|
          presenter.display_location \
            location:   location,
            highlight:  (location.pred && location.pred.label),
            context:    0..0,
            emphasisis: :path,
            cwd:        cwd
        }
      ].join("")
    end
  end
end
