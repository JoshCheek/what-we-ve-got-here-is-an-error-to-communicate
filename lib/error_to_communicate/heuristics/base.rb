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

      def classname
        einfo.classname
      end

      def backtrace
        einfo.backtrace
      end

      def explanation
        einfo.message
      end

      def semantic_explanation
        [:message, einfo.message]
      end

      def helpful_info
        [:null]
      end
    end
  end
end
