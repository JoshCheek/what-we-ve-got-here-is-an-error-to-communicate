require 'rouge'
require 'error_to_communicate/heuristic'
require 'error_to_communicate/levenshtein'

module ErrorToCommunicate
  class Heuristic
    class NoMethodError < Heuristic
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
          "You called the method `#{undefined_method_name}' on `#{name_of_ivar}', which is nil\nPossible misspelling of `#{closest_name}'"
        else
          super
        end
      end

      private

      # FIXME:
      # Needs to be able to deal with situations like
      # the line number being within a multiline expression
      def name_of_ivar
        return @name_of_ivar if defined? @name_of_ivar
        file = File.read(einfo.backtrace.first.path)
        line = file.lines.to_a[einfo.backtrace.first.linenum-1]

        tokens = Rouge::Lexers::Ruby.lex(line).to_a
        index  = tokens.index { |token, text| text == undefined_method_name }

        if !index
          return nil
          # this happens when the tokens don't match the name, eg
          # method name of "[]", and tokens of:
          # [[<Token Punctuation>, "["],
          #  [<Token Literal.Number.Integer>, "0"],
          #  [<Token Punctuation>, "]"]]
        end

        while 0 <= index
          token, text = tokens[index]
          break if token.qualname == "Name.Variable.Instance"
          index -= 1
        end

        @name_of_ivar = if index == -1
          nil
        else
          token, text = tokens[index]
          text
        end
      end

      def existing_ivars
        # TODO: this should get pushed into the location
        binding = einfo.backtrace[0].binding
        return [] unless binding
        binding.eval('self').instance_variables
      end

      def misspelling?
        name_of_ivar && closest_name &&
          Levenshtein.call(closest_name, name_of_ivar) <= 2
      end

      def closest_name
        @closest_name ||= existing_ivars.min_by { |varname| Levenshtein.call varname, name_of_ivar }
      end

      def self.parse_undefined_name(message)
        message[/`(.*)'/, 1]
      end
    end
  end
end
