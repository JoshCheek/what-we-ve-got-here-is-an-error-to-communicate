module ErrorToCommunicate
  module Heuristics
    class Base
      def self.for?(einfo)
        raise NotImplementedError, "#{self} needs to implement .for? (subclass responsibility)"
      end

      attr_accessor :einfo

      def initialize(einfo)
        self.einfo = einfo
      end

      def backtrace
        einfo.backtrace
      end

      # TODO: Push this somewhere higher
      def format_for_terminal(theme, format_code)
        self.class::FormatTerminal.new \
          theme:          theme,
          heuristic:      self,
          einfo:          einfo,
          format_code:    format_code
      end
    end
  end
end
