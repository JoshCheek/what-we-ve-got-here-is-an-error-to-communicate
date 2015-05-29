require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class NoMethodError < Heuristic
      def self.for?(einfo)
        einfo.classname == 'NoMethodError'
      end

      def undefined_method_name
        words = einfo.message.split(/\s+/)
        words[2][1...-1]
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
    end
  end
end