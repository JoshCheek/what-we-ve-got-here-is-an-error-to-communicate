module WhatWeveGotHereIsAnErrorToCommunicate
  # Wraps an exception in our internal data structures
  # So we can normalize the different things that come in,
  # and you can use code that needs this info without
  # going to the effort of raising exceptions
  class ExceptionInfo
    attr_accessor :classname
    attr_accessor :message
    attr_accessor :backtrace

    def initialize(attributes)
      self.exception = attributes.fetch :exception, nil
      self.classname = attributes.fetch :classname
      self.message   = attributes.fetch :message
      self.backtrace = attributes.fetch :backtrace
    end

    attr_writer :exception
    private     :exception=
    def exception
      @warned_about_exception ||= begin
        warn "The exception is recorded for debugging purposes only.\n"
        warn "Don't write code that depends on it, or we can't generically use the ExceptionInfo structure."
        true
      end
      @exception
    end
  end

  class ExceptionInfo::Location
    # TODO: rename linenum -> line_number
    attr_accessor :path, :linenum, :label, :pred, :succ
    def initialize(attributes)
      self.path    = attributes.fetch :path
      self.linenum = attributes.fetch :linenum
      self.label   = attributes.fetch :label
      self.pred    = attributes.fetch :pred, nil
      self.succ    = attributes.fetch :succ, nil
    end
  end
end
