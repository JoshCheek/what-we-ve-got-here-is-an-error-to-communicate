require 'error_to_communicate/format_terminal/helpers'

# Temporary extraction so I can see what's going on and do some refactorings.
module ErrorToCommunicate
  class FormatTerminal
    module Heuristics
      class WrongNumberOfArguments
        include FormatTerminal::Helpers

        attr_accessor :info, :cwd, :heuristic, :theme

        def initialize(heuristic, exception_info, theme, cwd)
          self.heuristic = heuristic
          self.theme     = theme
          self.info      = exception_info
          self.cwd       = cwd
        end

        def header
          [ "#{theme.white}#{info.classname} | "\
            "#{theme.bri_red}#{heuristic.explanation} "\
            "#{theme.dim_red}(expected #{theme.white}#{heuristic.num_expected},"\
            "#{theme.dim_red} sent #{theme.white}#{heuristic.num_received}"\
            "#{theme.dim_red})"\
            "#{theme.none}\n"
          ]
        end

        def helpful_info
          [ display_location(location:   info.backtrace[0],
                             highlight:  info.backtrace[0].label,
                             context:    0..5,
                             message:    "EXPECTED #{heuristic.num_expected}",
                             emphasisis: :code,
                             cwd:        cwd),
            display_location(location:   info.backtrace[1],
                             highlight:  info.backtrace[0].label,
                             context:    -5..5,
                             message:    "SENT #{heuristic.num_received}",
                             emphasisis: :code,
                             cwd:        cwd)
          ]
        end
      end
    end
  end
end
