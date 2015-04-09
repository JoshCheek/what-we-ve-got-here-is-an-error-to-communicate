require 'pathname'
require 'error_to_communicate/format/heuristic'
require 'error_to_communicate/format/display_location'
require 'error_to_communicate/format/terminal_helpers'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    def self.call(exception_info, cwd)
      new(exception_info, cwd).call
    end

    include Format::Heuristic
    include Format::DisplayLocation
    include Format::TerminalHelpers

    attr_accessor :info, :cwd

    def initialize(exception_info, cwd)
      self.info, self.cwd = exception_info, cwd
    end

    def call
      display ||= begin
        # Display the ArgumentError
        [ separator_line,
          display_class_and_message(info),

          separator_line,
          *heuristic(info, cwd),

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

    def display_class_and_message(info) # FIXME: obviously shitty
      if info.classname == 'ArgumentError'
        "#{white}#{info.classname} | "\
        "#{bri_red}#{info.explanation} "\
        "#{dim_red}(expected #{white}#{info.num_expected},"\
        "#{dim_red} sent #{white}#{info.num_received}"\
        "#{dim_red})"\
        "#{none}\n"
      else
        "#{white}#{info.classname} | "\
        "#{bri_red}#{info.explanation} "\
        "#{none}\n"
      end
    end
  end
end
