require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class Exception < Heuristic
      autoload :TerminalFormatter, File.expand_path('terminal_formatter', __dir__)

      def self.for?(einfo)
        true
      end

      def semantic_info
        [:code, {
          location:   backtrace[0],
          highlight:  backtrace[0].label,
          context:    -5..5,
          emphasisis: :code,
        }]
      end
    end
  end
end
