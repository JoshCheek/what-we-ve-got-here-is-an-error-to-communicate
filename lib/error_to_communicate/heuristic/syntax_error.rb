require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class SyntaxError < Heuristic
      def self.for?(einfo)
        einfo.classname == 'SyntaxError' && parse_message(einfo.message)
      end


      attr_accessor :reported_file, :reported_line, :unexpected, :expected, :invalid_loc

      def initialize(*)
        super
        self.reported_file ,
        self.reported_line ,
        self.unexpected    ,
        self.expected      = self.class.parse_message(einfo.message)
        self.invalid_loc   = ExceptionInfo::Location.new \
                               path:    reported_file,
                               linenum: reported_line,
                               label:   "unexpected #{unexpected}, expected: #{expected}",
                               pred:    backtrace[0]
      end

      def semantic_info
        [:heuristic,
          [:code, {
            location:  invalid_loc,
            context:   -5..5,
            message:   "unexpected #{unexpected}, expected #{expected}",
            emphasis:  :code,
          }]
        ]
      end

      def semantic_explanation
        [ :message,
          [ [:context, 'Unexpected '],
            [:details, unexpected],
            [:context, ', expected'],
            [:details, expected],
          ]
        ]
      end

      # "/Users/josh/code/what-we-ve-got-here-is-an-error-to-communicate/proving_grounds/simple_syntax_error.rb:2: syntax error, unexpected end-of-input, expecting keyword_end"
      def self.parse_message(message)
        return if message !~ /^(.*?):(\d+):.*?unexpected (.*?), expecting (.*)$/
        file, line, unexpected, expected = $1, $2.to_i, $3, $4
        [file, line, unexpected, expected]
      end
    end
  end
end
