module WhatWeveGotHereIsAnErrorToCommunicate
  class ExceptionInfo
    attr_accessor :classname,
                  :explanation,
                  :num_expected,
                  :num_received,
                  :undefined_method_name,
                  :backtrace

    def initialize(attributes)
      self.classname             = attributes.fetch :classname
      self.explanation           = attributes.fetch :explanation
      self.num_expected          = attributes.fetch :num_expected,          nil # too custom to ArgumentError
      self.num_received          = attributes.fetch :num_received,          nil # too custom to ArgumentError
      self.undefined_method_name = attributes.fetch :undefined_method_name, nil # too custom to NoMethodError
      self.backtrace             = attributes.fetch :backtrace
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
