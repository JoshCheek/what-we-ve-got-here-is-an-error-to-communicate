require 'coderay'
require 'pathname'

module DispayErrors
  class ArgumentError
    def initialize(exception)
      @exception     = exception
      @parsed        = parse_message exception.message
      @explanation   = @parsed.fetch :explanation
      @num_expected  = @parsed.fetch :num_expected
      @num_received  = @parsed.fetch :num_received
      @backtrace     = Backtrace.new exception.backtrace
      @callee_code   = Location.from_backtrace_line exception.backtrace[0],
                                                    context:   0..5,
                                                    message:   "EXPECTED #{@parsed.fetch :num_expected}"
      @caller_code   = Location.from_backtrace_line exception.backtrace[1],
                                                    next_meth: @callee_code.crnt_meth,
                                                    context:   -5..5,
                                                    message:   "SENT #{@parsed.fetch :num_received}"
    end

    def to_s
      @to_s ||= begin
        display = ""
        display << separator
        display << class_and_message(@exception.class, @parsed) << "\n"
        display << separator
        display << @callee_code.to_s
        display << "\n"
        display << @caller_code.to_s
        display << separator
        display << @backtrace.to_s
      end
    end

    private

    def separator
      ("="*70) << "\n"
    end

    # Obviously not all ArgumentErrors are "wrong number of arguments", but it's a proof of concept
    def parse_message(message)
      nums = message.scan /\d+/
      { explanation:  message[/^[^\(]*/].strip,
        num_expected: nums[1].to_i,
        num_received: nums[0].to_i,
      }
    end

    def class_and_message(type, parsed)
      white   = "\e[38;5;255m"
      bri_red = "\e[38;5;196m"
      dim_red = "\e[38;5;124m"
      none    = "\e[39m"
      "#{white}#{type} | "\
      "#{bri_red}#{parsed.fetch :explanation} "\
      "#{dim_red}(expected #{white}#{parsed.fetch :num_expected},"\
      "#{dim_red} sent #{white}#{parsed.fetch :num_received}"\
      "#{dim_red})"\
      "#{none}"
    end
  end


  class Backtrace
    def initialize(backtrace, cwd:Dir.pwd)
      @backtrace = backtrace
      @cwd       = cwd
    end

    def to_s
      @to_s ||= @backtrace.each_with_object([]) { |line, locations|
        opts             = {cwd: @cwd, emphasize_path: true}
        next_loc         = locations.last
        opts[:next_meth] = next_loc.crnt_meth if next_loc
        locations << Location.from_backtrace_line(line, opts)
      }.join("")
    end
  end


  class Location
    def self.from_backtrace_line(line, **options)
      filepath   = line[/^[^:]+/]
      linenum    = line[/:(\d+):/,  1].to_i
      methodname = line[/`(.*?)'$/, 1]
      options    = { crnt_meth: methodname,
                     next_meth: methodname,
                   }.merge(options)
      new filepath, linenum, **options
    end

    attr_reader :crnt_meth, :next_meth, :filepath, :linenum

    def initialize(filepath, linenum, next_meth: "", crnt_meth: "", context:0..0, message:"", cwd:Dir.pwd, emphasize_path: false)
      @filepath       = Pathname.new File.expand_path(filepath, cwd)
      @cwd            = Pathname.new cwd
      @emphasize_path = emphasize_path
      @message        = message
      @crnt_meth      = crnt_meth
      @next_meth      = next_meth
      line_index      = linenum - 1
      @linenum        = linenum
      @end_index      = bound_num(line_index + context.end,   min: 0)
      @start_index    = bound_num(line_index + context.begin, min: 0)
      @message_offset = line_index - @start_index
    end

    def to_s
      @to_s ||= begin
        # first line gives the path
        path_line = ""
        path_line << color_path("#{path_to_dir @cwd, @filepath}/")
        path_line << color_filename(@filepath.basename)
        path_line << ":" << color_linenum(@linenum)

        # then display the code
        code = File.read(@filepath).lines[@start_index..@end_index].join("")
        code = remove_indentation code
        code = CodeRay.encode     code, :ruby, :terminal
        code = prefix_linenos_to  code, @start_index.next
        code = indent             code, "  "
        code = add_message_to     code, @message_offset, screaming_red(@message)
        code = highlight_text     code, @message_offset, @next_meth

        # adjust for emphasization
        if @emphasize_path
          path_line = underline path_line
          code = indent         code, "      "
          code = desaturate     code
          code = highlight_text code, @message_offset, @next_meth # b/c desaturate really strips color
        end

        # all together
        path_line << "\n" << code
      end
    end

    private

    def bound_num(num, min:)
      num < min ? min : num
    end

    def path_to_dir(from, to)
      to.relative_path_from(from).dirname
    end

    def remove_indentation(code)
      indentation = code.scan(/^\s*/).min_by(&:length)
      code.gsub(/^#{indentation}/, "")
    end

    def prefix_linenos_to(code, start_linenum)
      lines         = code.lines
      max_linenum   = lines.count + start_linenum - 1 # 1 to translate to indexes
      linenum_width = max_linenum.to_s.length + 1     # 1 for the colon
      lines.zip(start_linenum..max_linenum)
           .map { |line, num|
             formatted_num = "#{num}:".ljust(linenum_width)
             color_linenum(formatted_num) << " " << line
           }.join("")
    end

    def add_message_to(code, offset, message)
      lines = code.lines
      lines[offset].chomp! << " " << message << "\n"
      lines.join("")
    end

    def highlight_text(code, index, text)
      lines = code.lines
      return code unless lines[index]
      lines[index].gsub!(text, "\e[7m#{text}\e[27m") # invert
      lines.join("")
    end

    def indent(str, indentation_str)
      str.gsub /^/, indentation_str
    end

    def screaming_red(text)
      return "" if text.empty?
      "\e[38;5;255;48;5;88m #{text} \e[39;49m" # bright white on medium red
    end

    def color_linenum(linenum)
      "\e[34m#{linenum}\e[39m"
    end

    def underline(str)
      "\e[4m#{str}\e[24m"
    end

    def color_path(str)
      "\e[38;5;36m#{str}\e[39m" # fg r:0, g:3, b:2 (out of 0..5)
    end

    def color_filename(str)
      "\e[38;5;49;1m#{str}\e[39m" # fg r:0, g:5, b:3 (out of 0..5)
    end

    def desaturate(str)
      nocolor = str.gsub(/\e\[[\d;]+?m/, "")
      allgray = nocolor.gsub(/^(.*?)\n?$/, "\e[38;5;240m\\1\e[39m\n")
      allgray
    end
  end
end
