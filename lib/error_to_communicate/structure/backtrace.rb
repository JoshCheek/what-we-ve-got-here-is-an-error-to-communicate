module WhatWeveGotHereIsAnErrorToCommunicate
  module Structure
    class Backtrace
      attr_accessor :backtrace
      def initialize(attributes)
        self.backtrace = attributes.fetch :locations
      end

      class Location
        attr_accessor :filepath, :linenum, :methodname, :pred, :succ
        def initialize(attributes)
          self.filepath   = attributes.fetch :filepath
          self.linenum    = attributes.fetch :linenum
          self.methodname = attributes.fetch :methodname
          self.pred       = attributes.fetch :pred, nil
          self.succ       = attributes.fetch :succ, nil
        end
      end
    end
  end
end
