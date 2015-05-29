require 'rouge'

module ErrorToCommunicate
  class FormatTerminal
    def self.call(attributes)
      cwd                 = attributes.fetch :cwd
      theme               = attributes.fetch :theme
      heuristic           = attributes.fetch :heuristic
      format_code         = FormatTerminal::Code.new theme: theme, cwd: cwd
      heuristic_formatter = heuristic.class::TerminalFormatter.new \
                           heuristic:      heuristic,
                           theme:          theme,
                           format_code:    format_code

      [ theme.separator_line,
        *heuristic_formatter.header,

        theme.separator_line,
        *heuristic_formatter.helpful_info,

        theme.separator_line,
        *heuristic.backtrace.map { |location| # backtrace formatter?
          format_code.call \
            location:   location,
            highlight:  (location.pred && location.pred.label),
            context:    0..0,
            emphasisis: :path
        }
      ].join("")
    end


    class Code
      attr_accessor :theme, :cwd

      def initialize(attributes)
        self.theme = attributes.fetch :theme
        self.cwd   = attributes.fetch :cwd
      end

      def call(attributes)
        location       = attributes.fetch :location
        path           = location.path
        line_index     = location.linenum - 1
        highlight      = attributes.fetch :highlight, location.label
        end_index      = bound_num min: 0, num: line_index+attributes.fetch(:context).end
        start_index    = bound_num min: 0, num: line_index+attributes.fetch(:context).begin
        message        = attributes.fetch :message, ''
        message_offset = line_index - start_index

        # first line gives the path
        path_line = [
          theme.color_path("#{path_to_dir cwd, path}/"),
          theme.color_filename(path.basename),
          ":",
          theme.color_linenum(location.linenum),
        ].join("")

        # then display the code
        if path.exist?
          code = File.read(path).lines[start_index..end_index].join("")
          code = remove_indentation       code
          code = theme.syntax_highlight   code
          code = prefix_linenos_to        code, start_index.next
          code = theme.indent             code, "  "
          code = add_message_to           code, message_offset, theme.screaming_red(message)
          code = theme.highlight_text           code, message_offset, highlight
        else
          code = "Can't find code\n"
        end

        # adjust for emphasization
        if attributes.fetch(:emphasisis) == :path
          path_line = theme.underline      path_line
          code      = theme.indent         code, "      "
          code      = theme.desaturate     code
          code      = theme.highlight_text code, message_offset, highlight # b/c desaturate really strips color
        end

        # all together
        path_line << "\n" << code
      end

      def path_to_dir(from, to)
        to.expand_path.relative_path_from(from).dirname
      rescue ArgumentError
        return to # eg rbx's core code
      end

      def bound_num(attributes)
        num = attributes.fetch :num
        min = attributes.fetch :min
        num < min ? min : num
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
               theme.color_linenum(formatted_num) << " " << line
             }.join("")
      end

      def add_message_to(code, offset, message)
        lines = code.lines
        lines[offset].chomp! << " " << message << "\n"
        lines.join("")
      end
    end
  end
end
