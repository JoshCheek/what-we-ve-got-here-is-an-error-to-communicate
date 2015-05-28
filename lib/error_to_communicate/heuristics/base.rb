module ErrorToCommunicate
  module Heuristics
    class Base
      def self.for?(einfo)
        raise NotImplementedError, "#{self} needs to implement .for? (subclass responsibility)"
      end

      attr_accessor :exception_info

      def initialize(exception_info)
        self.exception_info = exception_info
      end

      # TODO: Push this somewhere higher
      def format_for_terminal(theme, format_code)
        self.class::FormatTerminal.new \
          theme:          theme,
          heuristic:      self,
          einfo:          exception_info,
          format_code:    format_code
      end
    end
  end
end
