require 'rouge'

module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    module TerminalHelpers
      def separator
        ("="*70) << "\n"
      end

      def color_path(str)
        "\e[38;5;36m#{str}\e[39m" # fg r:0, g:3, b:2 (out of 0..5)
      end

      def color_linenum(linenum)
        "\e[34m#{linenum}\e[39m"
      end

      def path_to_dir(from, to)
        to.relative_path_from(from).dirname
      rescue ArgumentError
        return to # eg rbx's core code
      end

      def white
        "\e[38;5;255m"
      end

      def bri_red
        "\e[38;5;196m"
      end

      def dim_red
        "\e[38;5;124m"
      end

      def none
        "\e[39m"
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
               color_linenum(formatted_num) << " " << line
             }.join("")
      end

      def add_message_to(code, offset, message)
        lines = code.lines
        lines[offset].chomp! # might return nil
        lines[offset] << " " << message << "\n"
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

      def underline(str)
        "\e[4m#{str}\e[24m"
      end

      def color_filename(str)
        "\e[38;5;49;1m#{str}\e[39m" # fg r:0, g:5, b:3 (out of 0..5)
      end

      def desaturate(str)
        nocolor = str.gsub(/\e\[[\d;]+?m/, "")
        allgray = nocolor.gsub(/^(.*?)\n?$/, "\e[38;5;240m\\1\e[39m\n")
        allgray
      end

      # For a list of themes:
      # https://github.com/JoshCheek/what-we-ve-got-here-is-an-error-to-communicate/issues/36#issuecomment-91200262
      def syntax_highlight(raw_code)
        formatter = Rouge::Formatters::Terminal256.new theme: 'colorful'
        lexer     = Rouge::Lexers::Ruby.new
        tokens    = lexer.lex raw_code
        formatter.format(tokens)
      end
    end
  end
end
