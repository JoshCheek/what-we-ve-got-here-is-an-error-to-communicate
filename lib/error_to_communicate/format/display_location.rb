# Temporary extraction so I can see what's going on and do some refactorings.
module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    module DisplayLocation
      def display_location(attributes)
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
        path_line = [
          color_path("#{path_to_dir cwd, path}/"),
          color_filename(path.basename),
          ":",
          color_linenum(location.linenum),
        ].join("")

        # then display the code
        if path.exist?
          code = File.read(path).lines[start_index..end_index].join("")
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
        path_line << "\n" << code
      end
    end
  end
end
