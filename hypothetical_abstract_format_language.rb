Format
  .new
  .partition.header { |error_type|
    error_type.title @info.classname
    error_type.subtext.class(:error) { |message|
      message.text @info.explanation
      message.deemphasize { |details|
        details.text '(expected '
        details.stands_out @info.num_expected
        details.text ', sent '
        details.stands_out @info.num_received
        details.text ')'
      }
    }
  }
  .partition { |heuristic|
    heuristic = display_location formatter:  heuristic,
                                 annotation: "expected #{@info.num_expected}",
                                 location:   @info.backtrace[0],
                                 highlight:  @info.backtrace[0].label,
                                 context:    0..5,
                                 emphasisis: :code

    heuristic = display_location formatter:  heuristic
                                 annotation: "SENT #{info.num_received}",
                                 location:   info.backtrace[1],
                                 highlight:  info.backtrace[0].label,
                                 context:    -5..5,
                                 emphasisis: :code
    heuristic
  }
  .partition { |fmt|
    info.backtrace.reduce(fmt) do |formatter, location|
      display_location formatter:  formatter,
                       location:   location,
                       highlight:  location.succ.label,
                       context:    0..0,
                       emphasisis: :path
    end
  }

def display_location(attributes)
  formatter      = attributes.fetch :formatter
  location       = attributes.fetch :location
  path           = Pathname.new location.path
  line_index     = location.linenum - 1
  highlight      = attributes.fetch :highlight, location.label
  end_index      = bound_num min: 0, num: line_index+attributes.fetch(:context).end
  start_index    = bound_num min: 0, num: line_index+attributes.fetch(:context).begin
  annotation     = attributes.fetch :annotation, ''
  message_offset = line_index - start_index
  emphasize_path = attributes.fetch(:emphasisis) == :path
  emphasize_code = attributes.fetch(:emphasisis) == :code
  raw_code       = path.exist? && File.read(path).lines[start_index..end_index].join("")

  formatter.segment :path_with_code { |fmt|
    display_path(
      formatter: fmt,
      class:     (:emphasize if emphasize_path),
      path:      path,
      linenum:   location.linenum,
    ).segment { |codeblock|
      codeblock.code raw_code:          raw_code || "Can't find code",
                     strip_indentation: true,
                     language:          :ruby,
                     starting_linenum:  start_index.next,
                     annotations:       [
                       { linenum:    message_offset,
                         annotation: message,
                         class:      error,
                       } if raw_code
                     ]
    }
  }
end


def display_path(attributes)
  # CALLED LIKE THIS:
  #   display_path(
  #     formatter: fmt,
  #     class:     (:emphasize if emphasize_path),
  #     path:      path,
  #     linenum:   location.linenum,
  # OLD IMPLEMENTATION:
  #   path_line = ""
  #   path_line << color_path("#{path_to_dir @cwd, path}/")
  #   path_line << color_filename(path.basename)
  #   path_line << ":" << color_linenum(location.linenum)
end
