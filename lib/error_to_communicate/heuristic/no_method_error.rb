require 'error_to_communicate/heuristic'

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

      private

      def self.parse_undefined_name(message)
        message[/`(.*)'/, 1]
      end
    end
  end
end
