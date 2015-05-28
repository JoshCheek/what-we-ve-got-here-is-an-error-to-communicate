module ErrorToCommunicate
  class FormatTerminal

    def self.call(attributes)
      new(attributes).call
    end

    attr_accessor :info, :theme, :heuristic_presenter, :format_code

    def initialize(attributes)
      self.theme               = attributes.fetch :theme
      self.info                = attributes.fetch :einfo
      self.heuristic_presenter = attributes.fetch :heuristic_formatter
      self.format_code         = attributes.fetch :format_code
    end

    def call
      [ theme.separator_line,
        *heuristic_presenter.header,

        theme.separator_line,
        *heuristic_presenter.helpful_info,

        theme.separator_line,
        *info.backtrace.map { |location|
          format_code.call \
            location:   location,
            highlight:  (location.pred && location.pred.label),
            context:    0..0,
            emphasisis: :path
        }
      ].join("")
    end
  end
end
