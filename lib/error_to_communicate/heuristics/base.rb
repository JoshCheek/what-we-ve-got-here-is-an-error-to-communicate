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
      def format_for_terminal(theme, cwd, presenter)
        self.class::FormatTerminal.new \
          cwd:            cwd,
          theme:          theme,
          heuristic:      self,
          exception_info: exception_info,
          presenter:      presenter
      end
    end
  end
end
