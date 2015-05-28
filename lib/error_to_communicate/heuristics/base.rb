module ErrorToCommunicate
  module Heuristics
    class Base
      # This should be in charge of autoloading formatters and things
      # ALSO: It's possible I'm doing too much work without the definite need, at the moment :/

      def self.for?(einfo)
        raise NotImplementedError, "#{self} needs to implement .for? (subclass responsibility)"
      end

      attr_accessor :exception_info

      def initialize(exception_info)
        self.exception_info = exception_info
      end
    end
  end
end
