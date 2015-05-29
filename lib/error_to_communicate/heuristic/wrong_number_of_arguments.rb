require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class WrongNumberOfArguments < Heuristic
      def self.for?(einfo)
        extract_from einfo
      end

      attr_accessor :explanation, :num_expected, :num_received

      def initialize(*)
        super
        self.num_received, self.num_expected = self.class.extract_from(einfo)
        self.explanation = 'Wrong number of arguments'
      end

      def semantic_explanation
        [ :message,
          [ [:explanation, explanation],
            [:context, ' (expected '],
            [:details, num_expected],
            [:context, ', sent '],
            [:details, num_received],
            [:context, ')'],
          ]
        ]
      end

      def semantic_info
        [ [:code, {
            location:  backtrace[0],
            highlight: backtrace[0].label,
            context:   0..5,
            message:   "EXPECTED #{num_expected}",
            emphasis:  :code,
          }],

          [:code, {
            location:  backtrace[1],
            highlight: backtrace[0].label,
            context:   -5..5,
            message:   "SENT #{num_received}",
            emphasis:  :code,
          }],
        ]
      end

      private

      def self.extract_from(einfo)
        case einfo.message
        when /^wrong number of arguments.*?\((\d+) for (\d+)\)$/ # MRI / JRuby
          num_received, num_expected = $1.to_i, $2.to_i
        when /^method '.*?': given (\d+).*? expected (\d+)$/ # RBX
          num_received, num_expected = $1.to_i, $2.to_i
        end
      end
    end
  end
end
