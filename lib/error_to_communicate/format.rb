require 'coderay'
require 'pathname'

module WhatWeveGotHereIsAnErrorToCommunicate
  def self.format(info)
    # FIXME: extract this into some sort of object
    separator = lambda do
      ("="*70) << "\n"
    end

    color_path = lambda do |str|
      "\e[38;5;36m#{str}\e[39m" # fg r:0, g:3, b:2 (out of 0..5)
    end

    color_linenum = lambda do |linenum|
      "\e[34m#{linenum}\e[39m"
    end

    path_to_dir = lambda do |from, to|
      to.relative_path_from(from).dirname
    end

    display_class_and_message = lambda do
      white   = "\e[38;5;255m"
      bri_red = "\e[38;5;196m"
      dim_red = "\e[38;5;124m"
      none    = "\e[39m"
      # FIXME:
      # Something else should set this?
      #   I'd say heuristic, but fact is that it needs formatting info.
      #   Maybe initially, heuristic contains both extracted info and formatting info?
      # Or maybe we want polymorphism at the formatter level?
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

    bound_num = lambda do |attributes|
      num = attributes.fetch :num
      min = attributes.fetch :min
      num < min ? min : num
    end

    remove_indentation = lambda do |code|
      indentation = code.scan(/^\s*/).min_by(&:length)
      code.gsub(/^#{indentation}/, "")
    end

    prefix_linenos_to = lambda do |code, start_linenum|
      lines         = code.lines
      max_linenum   = lines.count + start_linenum - 1 # 1 to translate to indexes
      linenum_width = max_linenum.to_s.length + 1     # 1 for the colon
      lines.zip(start_linenum..max_linenum)
           .map { |line, num|
             formatted_num = "#{num}:".ljust(linenum_width)
             color_linenum.call(formatted_num) << " " << line
           }.join("")
    end

    add_message_to = lambda do |code, offset, message|
      lines = code.lines
      lines[offset].chomp! << " " << message << "\n"
      lines.join("")
    end

    highlight_text = lambda do |code, index, text|
      lines = code.lines
      return code unless lines[index]
      lines[index].gsub!(text, "\e[7m#{text}\e[27m") # invert
      lines.join("")
    end

    indent = lambda do |str, indentation_str|
      str.gsub /^/, indentation_str
    end

    screaming_red = lambda do |text|
      return "" if text.empty?
      "\e[38;5;255;48;5;88m #{text} \e[39;49m" # bright white on medium red
    end

    underline = lambda do |str|
      "\e[4m#{str}\e[24m"
    end

    color_filename = lambda do |str|
      "\e[38;5;49;1m#{str}\e[39m" # fg r:0, g:5, b:3 (out of 0..5)
    end

    desaturate = lambda do |str|
      nocolor = str.gsub(/\e\[[\d;]+?m/, "")
      allgray = nocolor.gsub(/^(.*?)\n?$/, "\e[38;5;240m\\1\e[39m\n")
      allgray
    end

    cwd = Dir.pwd

    display_location = lambda do |attributes|
      location       = attributes.fetch :location
      cwd            = Pathname.new attributes.fetch(:cwd)
      filepath       = Pathname.new File.expand_path(location.filepath, cwd)
      line_index     = location.linenum - 1
      highlight      = attributes.fetch :highlight, location.methodname
      end_index      = bound_num.call min: 0, num: line_index+attributes.fetch(:context).end
      start_index    = bound_num.call min: 0, num: line_index+attributes.fetch(:context).begin
      message        = attributes.fetch :message, ''
      message_offset = line_index - start_index

      # first line gives the path
      path_line = ""
      path_line << color_path.call("#{path_to_dir.call cwd, filepath}/")
      path_line << color_filename.call(filepath.basename)
      path_line << ":" << color_linenum.call(location.linenum)

      # then display the code
      code = File.read(filepath).lines[start_index..end_index].join("")
      code = remove_indentation.call code
      code = CodeRay.encode          code, :ruby, :terminal
      code = prefix_linenos_to.call  code, start_index.next
      code = indent.call             code, "  "
      code = add_message_to.call     code, message_offset, screaming_red.call(message)
      code = highlight_text.call     code, message_offset, highlight

      # adjust for emphasization
      if attributes.fetch(:emphasisis) == :path
        path_line = underline.call path_line
        code = indent.call         code, "      "
        code = desaturate.call     code
        code = highlight_text.call code, message_offset, highlight # b/c desaturate really strips color
      end

      # all together
      path_line << "\n" << code
    end


    # Display the ArgumentError
    display = ""
    display << separator.call
    display << display_class_and_message.call << "\n"

    # Display the Heuristic
    display << separator.call

    # FIXME: Some sort of polymorphism or normalization would be way better here, too
    # And, at the very least, not switching on classname, but some more abstract piece of info,
    # b/c classnames are not completely consistent across the implementations
    # (eg: https://github.com/JoshCheek/seeing_is_believing/blob/cc93b4ee3a83145509c235f64d9454dc3e12d8c9/lib/seeing_is_believing/event_stream/producer.rb#L54-55)
    if info.classname == 'ArgumentError'
      display << display_location.call(location:   info.backtrace[0],
                                       highlight:  info.backtrace[0].methodname,
                                       context:    0..5,
                                       message:    "EXPECTED #{info.num_expected}",
                                       emphasisis: :code,
                                       cwd:        cwd)
      display << "\n"
      display << display_location.call(location:   info.backtrace[1],
                                       highlight:  info.backtrace[0].methodname,
                                       context:    -5..5,
                                       message:    "SENT #{info.num_received}",
                                       emphasisis: :code,
                                       cwd:        cwd)
    elsif info.classname == 'NoMethodError'
      display << display_location.call(location:   info.backtrace[0],
                                       highlight:  info.backtrace[0].methodname,
                                       context:    -5..5,
                                       message:    "#{info.undefined_method_name} is undefined",
                                       emphasisis: :code,
                                       cwd:        cwd)
    else
      display << display_location.call(location:   info.backtrace[0],
                                       highlight:  info.backtrace[0].methodname,
                                       context:    -5..5,
                                       emphasisis: :code,
                                       cwd:        cwd)
    end

    # display the backtrace
    display << separator.call
    display << display_location.call(location:   info.backtrace[0],
                                     highlight:  info.backtrace[0].methodname,
                                     context:    0..0,
                                     emphasisis: :path,
                                     cwd:        cwd)

    display << info.backtrace.each_cons(2).map { |next_loc, crnt_loc|
      display_location.call location:   crnt_loc,
                            highlight:  next_loc.methodname,
                            context:    0..0,
                            emphasisis: :path,
                            cwd:        cwd
    }.join("")

    display
  end
end
