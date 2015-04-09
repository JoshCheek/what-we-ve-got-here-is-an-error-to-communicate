require 'pathname'
require 'error_to_communicate/format/terminal_helpers'

module WhatWeveGotHereIsAnErrorToCommunicate
  extend Format::TerminalHelpers
  def self.format(info)
    cwd = Dir.pwd

    # FIXME:
    # Something else should set this?
    #   I'd say heuristic, but fact is that it needs formatting info.
    #   Maybe initially, heuristic contains both extracted info and formatting info?
    # Or maybe we want polymorphism at the formatter level?
    display_class_and_message = lambda do |info|
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

    display_location = lambda do |attributes|
      location       = attributes.fetch :location
      cwd            = Pathname.new attributes.fetch(:cwd)
      path           = Pathname.new location.path
      line_index     = location.linenum - 1
      highlight      = attributes.fetch :highlight, location.label
      end_index      = bound_num min: 0, num: line_index+attributes.fetch(:context).end
      start_index    = bound_num min: 0, num: line_index+attributes.fetch(:context).begin
      message        = attributes.fetch :message, ''
      message_offset = line_index - start_index

      # first line gives the path
      path_line = ""
      path_line << color_path("#{path_to_dir cwd, path}/")
      path_line << color_filename(path.basename)
      path_line << ":" << color_linenum(location.linenum)

      # then display the code
      if path.exist?
        code = File.read(path).lines[start_index..end_index].join("").chomp
        code = remove_indentation code
        code = syntax_highlight   code
        code = prefix_linenos_to  code, start_index.next
        code = indent             code, "  "
        code = add_message_to     code, message_offset, screaming_red(message)
        code = highlight_text     code, message_offset, highlight
      else
        code = "Can't find code\n"
      end

      # adjust for emphasization
      if attributes.fetch(:emphasisis) == :path
        path_line = underline path_line
        code = indent         code, "      "
        code = desaturate     code
        code = highlight_text code, message_offset, highlight # b/c desaturate really strips color
      end

      # all together
      code << "\n" unless code.end_with? "\n"
      path_line << "\n" << code
    end


    # Display the ArgumentError
    display = ""
    display << separator
    display << display_class_and_message.call(info) << "\n"

    # Display the Heuristic
    display << separator

    # FIXME: Some sort of polymorphism or normalization would be way better here, too
    # And, at the very least, not switching on classname, but some more abstract piece of info,
    # b/c classnames are not completely consistent across the implementations
    # (eg: https://github.com/JoshCheek/seeing_is_believing/blob/cc93b4ee3a83145509c235f64d9454dc3e12d8c9/lib/seeing_is_believing/event_stream/producer.rb#L54-55)
    if info.classname == 'ArgumentError'
      display << display_location.call(location:   info.backtrace[0],
                                       highlight:  info.backtrace[0].label,
                                       context:    0..5,
                                       message:    "EXPECTED #{info.num_expected}",
                                       emphasisis: :code,
                                       cwd:        cwd)
      display << "\n"
      display << display_location.call(location:   info.backtrace[1],
                                       highlight:  info.backtrace[0].label,
                                       context:    -5..5,
                                       message:    "SENT #{info.num_received}",
                                       emphasisis: :code,
                                       cwd:        cwd)
    elsif info.classname == 'NoMethodError'
      display << display_location.call(location:   info.backtrace[0],
                                       highlight:  info.backtrace[0].label,
                                       context:    -5..5,
                                       message:    "#{info.undefined_method_name} is undefined",
                                       emphasisis: :code,
                                       cwd:        cwd)
    else
      display << display_location.call(location:   info.backtrace[0],
                                       highlight:  info.backtrace[0].label,
                                       context:    -5..5,
                                       emphasisis: :code,
                                       cwd:        cwd)
    end

    # display the backtrace
    display << separator
    display << display_location.call(location:   info.backtrace[0],
                                     highlight:  info.backtrace[0].label,
                                     context:    0..0,
                                     emphasisis: :path,
                                     cwd:        cwd)

    display << info.backtrace.each_cons(2).map { |next_loc, crnt_loc|
      display_location.call location:   crnt_loc,
                            highlight:  next_loc.label,
                            context:    0..0,
                            emphasisis: :path,
                            cwd:        cwd
    }.join("")

    display
  end
end
