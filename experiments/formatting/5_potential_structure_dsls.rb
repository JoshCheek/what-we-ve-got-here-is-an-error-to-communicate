# a bunch of different options for what the DSL could look like

def display_location(attributes)
  formatter      = attributes.fetch :formatter
  location       = attributes.fetch :location
  path           = Pathname.new location.path
  line_index     = location.linenum - 1
  highlight      = attributes.fetch :highlight, location.label # currently ignoring this, b/c we can't highlight into the middle of the syntax highlighted output
  end_index      = bound_num min: 0, num: line_index+attributes.fetch(:context).end
  start_index    = bound_num min: 0, num: line_index+attributes.fetch(:context).begin
  annotation     = attributes.fetch :annotation, ''
  message_offset = line_index - start_index
  emphasize_path = attributes.fetch(:emphasisis) == :path
  raw_code       = path.exist? && File.read(path).lines[start_index..end_index].join("")

  # explicitly call begin to make the next call a node, call .end to leave
  formatter
    .begin.group(:path_with_code)
      .begin.group(:path, emphasize_path&&:emphasize)
        .text(:dir,         path_to_dir(@cwd, path, '/'))
        .text(:filename,    path.basename)
        .text(:separator,   ":")
        .text(:line_number, location.linenum)
      .end
      .begin.code(raw_code || "Can't find code")
        .strip_indentation(true)
        .language(:ruby)
        .starting_linenum(start_index.next)
        .if(raw_code).annotate(:error, annotate, line: message_offset)
      .end
    .end

  # leaves get !, use .end to end a node
  formatter
    .group(:path_with_code)
      .group(:path, emphasize_path&&:emphasize)
        .text!(:dir,         path_to_dir(@cwd, path, '/'))
        .text!(:filename,    path.basename)
        .text!(:separator,   ":")
        .text!(:line_number, location.linenum)
      .end
      .code(raw_code || "Can't find code")
        .strip_indentation!
        .language!(:ruby)
        .starting_linenum!(start_index.next)
        .if(raw_code)
          .annotate!(:error, annotate, line: message_offset)
        .end
      .end
    .end

  # nodes get !
  formatter
    .group!(:path_with_code)
      .group!(:path, emphasize_path&&:emphasize)
        .text(:dir,         path_to_dir(@cwd, path, '/'))
        .text(:filename,    path.basename)
        .text(:separator,   ":")
        .text(:line_number, location.linenum)
      .end
      .code!(raw_code || "Can't find code")
        .strip_indentation
        .language(:ruby)
        .starting_linenum(start_index.next)
        .if!(raw_code)
          .annotate(:error, annotate, line: message_offset)
        .end
      .end
    .end

  # swapping self
  formatter.eval prototype: self do
    group :path_with_code do
      group :path, emphasize_path&&:emphasize do
        text :dir,         path_to_dir(@cwd, path, '/')
        text :filename,    path.basename
        text :separator,   ":"
        text :line_number, location.linenum
      end
      code raw_code||"Can't find code" do
        language :ruby
        strip_indentation
        starting_linenum start_index.next
        annotate :error, annotate, line: message_offset if raw_code
      end
    end
  end
end
