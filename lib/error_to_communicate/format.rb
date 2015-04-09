require 'pathname'
require 'error_to_communicate/format/heuristic'
require 'error_to_communicate/format/display_location'
require 'error_to_communicate/format/terminal_helpers'

module WhatWeveGotHereIsAnErrorToCommunicate
  def self.format(exception_info, cwd)
    Format.new(exception_info, cwd).call
  end

  class Format
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
        display = ""
        display << separator
        display << display_class_and_message(info) << "\n"

        # Display the Heuristic
        display << separator
        display << heuristic(info, cwd)

        # display the backtrace
        display << separator
        display << display_location(location:   info.backtrace[0],
                                    highlight:  info.backtrace[0].label,
                                    context:    0..0,
                                    emphasisis: :path,
                                    cwd:        cwd)

        display << info.backtrace.each_cons(2).map { |next_loc, crnt_loc|
          display_location location:   crnt_loc,
                           highlight:  next_loc.label,
                           context:    0..0,
                           emphasisis: :path,
                           cwd:        cwd
        }.join("")

        display
      end
    end

    def display_class_and_message(info) # FIXME: obviously shitty
      if info.classname == 'ArgumentError'
        "#{white}#{info.classname} | "\
        "#{bri_red}#{info.explanation} "\
        "#{dim_red}(expected #{white}#{info.num_expected},"\
        "#{dim_red} sent #{white}#{info.num_received}"\
        "#{dim_red})"\
        "#{none}"
      else
        "#{white}#{info.classname} | "\
        "#{bri_red}#{info.explanation} "\
        "#{none}"
      end
    end
  end
end
