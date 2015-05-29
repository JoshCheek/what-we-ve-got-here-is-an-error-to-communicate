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

      def message
        einfo.message
      end

      def semantic_message
        raise NotImplementedError, "#{self} needs to implement #semantic_message (subclass responsibility)"
      end
    end
  end
end
