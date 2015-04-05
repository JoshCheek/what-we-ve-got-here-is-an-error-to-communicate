module WhatWeveGotHereIsAnErrorToCommunicate
  class ExceptionInfo
    attr_accessor :classname, :explanation, :backtrace
    attr_accessor :exception # for dev info only, parse out additional info rather than interacting with it direclty
    def initialize(attributes)
      self.exception   = attributes.fetch :exception, nil
      self.classname   = attributes.fetch :classname
      self.explanation = attributes.fetch :explanation
      self.backtrace   = attributes.fetch :backtrace
    end
  end

  class ExceptionInfo::Location
    # TODO: rename linenum -> line_number
    attr_accessor :filepath, :linenum, :methodname, :pred, :succ
    def initialize(attributes)
      self.filepath   = attributes.fetch :filepath
      self.linenum    = attributes.fetch :linenum
      self.methodname = attributes.fetch :methodname
      self.pred       = attributes.fetch :pred, nil
      self.succ       = attributes.fetch :succ, nil
    end
  end

  class ExceptionInfo::ArgumentError < ExceptionInfo
    attr_accessor :num_expected, :num_received
    def initialize(attributes)
      self.num_expected = attributes.fetch :num_expected
      self.num_received = attributes.fetch :num_received
      super
    end
  end

  class ExceptionInfo::NoMethodError < ExceptionInfo
    attr_accessor :undefined_method_name
    def initialize(attributes)
      self.undefined_method_name = attributes.fetch :undefined_method_name
      super
    end
  end
end
