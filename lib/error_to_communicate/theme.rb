module ErrorToCommunicate
  class Theme
    # -----  Semantic  -----
    # TODO: Not good enough, see note on FormatTerminal#format

    def columns(*content)
      content.join(' | ') + "\n"
    end

    def classname(classname)
      "#{white}#{classname}#{none}"
    end

    def message(message)
      "#{bri_red}#{message}#{none}"
    end

    def explanation(explanation)
      "#{bri_red}#{explanation}#{none}"
    end

    def context(context)
      "#{dim_red}#{context}#{none}"
    end

    def details(details)
      "#{white}#{details}#{none}"
    end

    # --------------------------------

    def separator_line
      ("="*70) << "\n"
    end

    def color_path(str)
      "\e[38;5;36m#{str}\e[39m" # fg r:0, g:3, b:2 (out of 0..5)
    end

    def color_linenum(linenum)
      "\e[34m#{linenum}\e[39m"
    end

    def invert(text)
      "\e[7m#{text}\e[27m"
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
      formatter = Rouge::Formatters::Terminal256.new theme: 'github'
      lexer     = Rouge::Lexers::Ruby.new
      tokens    = lexer.lex raw_code
      formatted = formatter.format(tokens)
      formatted << "\n" unless formatted.end_with? "\n"
      remove_ansi_codes_after_last_newline(formatted)
    end

    def remove_ansi_codes_after_last_newline(text)
      *neck, ass = text.lines # ... kinda like head/tail :P
      return text unless neck.any? && ass[/^(\e\[(\d+;?)*m)*$/]
      neck.join("").chomp << ass
    end

    def highlight_text(code, index, text)
      lines = code.lines
      return code unless text && lines[index]
      lines[index].gsub! text, invert(text)
      lines.join("")
    end

    def indent(str, indentation_str)
      str.gsub /^/, indentation_str
    end

    # TODO: rename these to all imply foreground
    def white
      fg_rgb 5, 5, 5
    end

    def bri_red
      fg_rgb 5, 0, 0
    end

    def dim_red
      fg_rgb 3, 0, 0
    end

    def none
      "\e[39m"
    end

    # Each of r, g, b, can have a value 0-5.
    # If you want to do 0-255, you need to pass 255 as max.
    # The terminal cans till only display 0-5,
    # but you can pass your rgb values in, and we'll translate them here
    def rgb(red, green, blue, max=6)
      max = max.to_f
      n   = 6

      # translate each colour to 0-5
      r = (n * red   / max).to_i
      g = (n * green / max).to_i
      b = (n * blue  / max).to_i

      # move them to their offsets, I think the first 16 are for the system colors
      16 + r*(n**2) + g*(n**1) + b*(n**0)
    end

    def fg_rgb(red, green, blue, max=6)
      "\e[38;5;#{rgb red, green, blue, max}m"
    end
  end
end
