require 'error_to_communicate/format/display_location'
require 'error_to_communicate/format/terminal_helpers'

# Temporary extraction so I can see what's going on and do some refactorings.
module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    module Heuristic

      # Okay, this should almost certainly be joined with the parsers
      def self.for(exception_info, cwd)
        case exception_info.classname
        when 'ArgumentError' # FIXME not sufficient (this is WrongNumberOfArugments)
          WrongNumberOfArguments.new(exception_info, cwd)
        when 'NoMethodError'
          NoMethodError.new(exception_info, cwd)
        else
          Exception.new(exception_info, cwd)
        end
      end

      class WrongNumberOfArguments
        include Format::DisplayLocation
        include Format::TerminalHelpers
        attr_accessor :info, :cwd

        def initialize(exception_info, cwd)
          self.info, self.cwd = exception_info, cwd
        end

        def header
          [ "#{white}#{info.classname} | "\
            "#{bri_red}#{info.explanation} "\
            "#{dim_red}(expected #{white}#{info.num_expected},"\
            "#{dim_red} sent #{white}#{info.num_received}"\
            "#{dim_red})"\
            "#{none}\n"
          ]
        end

        def helpful_info
          [ display_location(location:   info.backtrace[0],
                             highlight:  info.backtrace[0].label,
                             context:    0..5,
                             message:    "EXPECTED #{info.num_expected}",
                             emphasisis: :code,
                             cwd:        cwd),
            display_location(location:   info.backtrace[1],
                             highlight:  info.backtrace[0].label,
                             context:    -5..5,
                             message:    "SENT #{info.num_received}",
                             emphasisis: :code,
                             cwd:        cwd)
          ]
        end
      end


      class NoMethodError
        include Format::DisplayLocation
        include Format::TerminalHelpers
        attr_accessor :info, :cwd

        def initialize(exception_info, cwd)
          self.info, self.cwd = exception_info, cwd
        end

        def header
          [ "#{white}#{info.classname} | "\
            "#{bri_red}#{info.explanation} "\
            "#{none}\n"
          ]
        end

        def helpful_info
          [display_location(location:   info.backtrace[0],
                            highlight:  info.backtrace[0].label,
                            context:    -5..5,
                            message:    "#{info.undefined_method_name} is undefined",
                            emphasisis: :code,
                            cwd:        cwd)
          ]
        end
      end


      class Exception
        include Format::DisplayLocation
        include Format::TerminalHelpers
        attr_accessor :info, :cwd

        def initialize(exception_info, cwd)
          self.info, self.cwd = exception_info, cwd
        end

        def header
          [ "#{white}#{info.classname} | "\
            "#{bri_red}#{info.explanation} "\
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
