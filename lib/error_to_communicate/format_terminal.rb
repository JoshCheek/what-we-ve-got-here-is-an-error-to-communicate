module ErrorToCommunicate
  class FormatTerminal
    def self.call(attributes)
      theme            = attributes.fetch :theme
      info             = attributes.fetch :einfo
      format_heuristic = attributes.fetch :format_heuristic
      format_code      = attributes.fetch :format_code

      [ theme.separator_line,
        *format_heuristic.header,

        theme.separator_line,
        *format_heuristic.helpful_info,

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
