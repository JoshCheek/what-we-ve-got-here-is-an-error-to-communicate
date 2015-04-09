require 'error_to_communicate/format/terminal_helpers'

# Temporary extraction so I can see what's going on and do some refactorings.
module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    module HeuristicPresenter

      class WrongNumberOfArguments
        include Format::TerminalHelpers

        attr_accessor :info, :cwd, :heuristic

        def initialize(heuristic, exception_info, cwd)
          self.info, self.cwd = exception_info, cwd
          self.heuristic = heuristic
        end

        def header
          [ "#{white}#{info.classname} | "\
            "#{bri_red}#{heuristic.explanation} "\
            "#{dim_red}(expected #{white}#{heuristic.num_expected},"\
            "#{dim_red} sent #{white}#{heuristic.num_received}"\
            "#{dim_red})"\
            "#{none}\n"
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


      class NoMethodError
        include Format::TerminalHelpers

        attr_accessor :info, :cwd, :heuristic

        def initialize(heuristic, exception_info, cwd)
          self.info, self.cwd = exception_info, cwd
          self.heuristic = heuristic
        end

        def header
          [ "#{white}#{info.classname} | "\
            "#{bri_red}#{heuristic.explanation} "\
            "#{none}\n"
          ]
        end

        def helpful_info
          [display_location(location:   info.backtrace[0],
                            highlight:  info.backtrace[0].label,
                            context:    -5..5,
                            message:    "#{heuristic.undefined_method_name} is undefined",
                            emphasisis: :code,
                            cwd:        cwd)
          ]
        end
      end


      class Exception
        include Format::TerminalHelpers

        attr_accessor :info, :cwd, :heuristic

        def initialize(heuristic, exception_info, cwd)
          self.info, self.cwd = exception_info, cwd
          self.heuristic = heuristic
        end

        def header
          [ "#{white}#{info.classname} | "\
            "#{bri_red}#{heuristic.explanation} "\
            "#{none}\n"
          ]
        end

        def helpful_info
          [display_location(location:   info.backtrace[0],
                            highlight:  info.backtrace[0].label,
                            context:    -5..5,
                            emphasisis: :code,
                            cwd:        cwd)
          ]
        end
      end
    end
  end
end
