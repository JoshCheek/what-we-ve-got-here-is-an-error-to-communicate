require 'rouge'
require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class NoMethodError < Heuristic
      attr_accessor :error_binding # <-- should really be on error info

      def self.for?(einfo)
        ( einfo.classname == 'NoMethodError' ||
          einfo.classname == 'NameError'
        ) && parse_undefined_name(einfo.message)
      end

      def undefined_method_name
        self.class.parse_undefined_name message
      end

      def semantic_info
        [:heuristic,
          [:code, {
            location:  backtrace[0],
            highlight: backtrace[0].label,
            context:   -5..5,
            message:   "#{undefined_method_name} is undefined",
            emphasis:  :code,
          }]
        ]
      end

      def semantic_explanation
        if misspelling?
          "You called the method `#{undefined_method_name}' on `#{name_of_receiver}', which is nil\nPossible misspelling of `#{closest_name}'"
        else
          super
        end
      end

      private

      def name_of_receiver
        file = File.read(einfo.backtrace.first.path)
        line = file.lines[einfo.backtrace.first.linenum-1]

        # FIXME:
        # Needs to be able to deal with situations like
        # the line number being within a multiline expression
        tokens = Rouge::Lexers::Ruby.lex(line).to_a
        index  = tokens.index { |token, text| text == undefined_method_name }

        while 0 <= index
          token, text = tokens[index]
          break if token.qualname == "Name.Variable.Instance"
          index -= 1
        end

        didnt_match = (index == -1)
        if didnt_match
          raise "Uhm..... :D"
        end

        token, text = tokens[index]
        text
      end

      def existing_ivars
        error_binding.receiver.instance_variables
      end

      def hamming_distance(a, b)
        1 # FIXME :D
      end

      def misspelling?
        hamming_distance(closest_name, name_of_receiver) <= 2
      end

      def closest_name
        existing_ivars.min_by { |varname| hamming_distance varname, name_of_receiver }
      end

      def self.parse_undefined_name(message)
        message[/`(.*)'/, 1]
      end
    end
  end
end
