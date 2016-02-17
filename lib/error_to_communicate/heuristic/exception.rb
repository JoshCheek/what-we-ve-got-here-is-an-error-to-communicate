require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class Exception < Heuristic
      def self.for?(einfo)
        true
      end

      def semantic_info
        [:heuristic, maybe_heuristic(backtrace)]
      end

      private

      def maybe_heuristic(backtrace)
        return [:null] if backtrace.empty?
        [:code, {
          location:  backtrace[0],
          highlight: backtrace[0].label,
          context:   -5..5,
          emphasis:  :code,
        }]
      end
    end
  end
end
