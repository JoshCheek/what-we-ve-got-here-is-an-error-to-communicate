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

      def format_for_terminal(theme, cwd)
        self.class::FormatTerminal.new(self, exception_info, theme, cwd)
      end
    end
  end
end
