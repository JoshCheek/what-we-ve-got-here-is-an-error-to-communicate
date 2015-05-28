require 'error_to_communicate/format_terminal/code'

module ErrorToCommunicate
  class FormatTerminal
    def self.call(attributes)
      cwd              = attributes.fetch :cwd
      theme            = attributes.fetch :theme
      heuristic        = attributes.fetch :heuristic
      format_code      = FormatTerminal::Code.new theme: theme, cwd: cwd
      format_heuristic = heuristic.format_for_terminal theme, format_code # TODO: rename to formatter_for_terminal

      [ theme.separator_line,
        *format_heuristic.header,

        theme.separator_line,
        *format_heuristic.helpful_info,

        theme.separator_line,
        *heuristic.exception_info.backtrace.map { |location| # TODO: backtrace formatter?
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
