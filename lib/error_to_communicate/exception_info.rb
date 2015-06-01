require 'pathname'

module ErrorToCommunicate
  class ExceptionInfo
  end
end

class ErrorToCommunicate::ExceptionInfo::Location
  attr_accessor :path, :linenum, :label, :pred, :succ

  def initialize(attributes)
    self.path    = Pathname.new attributes.fetch(:path)
    self.linenum = attributes.fetch :linenum
    self.label   = attributes.fetch :label
    self.pred    = attributes.fetch :pred, nil
    self.succ    = attributes.fetch :succ, nil
  end

  # What if the line doesn't match for some reason?
  # Raise an exception?
  # Use some reasonable default? (is there one?)
  def self.parse(line)
    line =~ /^(.*?):(\d+):in `(.*?)'$/ # Are ^ and $ sufficient? Should be \A and (\Z or \z)?
    ErrorToCommunicate::ExceptionInfo::Location.new(
      path:    ($1||""),
      linenum: ($2||"-1").to_i,
      label:   ($3||line),
    )
  end

  # is there an upper bound I need to stay within? Guessing 30 or 31 bits,
  # but maybe it doesn't really matter?
  def hash
    path.hash + linenum.hash + label.hash
  end

  def ==(location)
    path    == location.path    &&
    linenum == location.linenum &&
    label   == location.label
  end

  alias eql? ==

  def inspect
    "#<ExInfo::Loc #{path}:#{linenum}:in `#{label}' pred:#{!!pred} succ:#{!!succ}>"
  end
end

# Wraps an exception in our internal data structures
# So we can normalize the different things that come in,
# and you can use code that needs this info without
# going to the effort of raising exceptions
class ErrorToCommunicate::ExceptionInfo
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

  def self.parseable?(exception)
    exception.respond_to?(:message) && exception.respond_to?(:backtrace)
  end

  def self.parse(exception)
    return exception if exception.kind_of? self
    new exception: exception,
        classname: exception.class.name,
        message:   exception.message,
        backtrace: parse_backtrace(exception.backtrace)
  end

  def self.parse_backtrace(backtrace)
    # Really, there are better methods, e.g. backtrace_locations,
    # but they're unevenly implemented across versions and implementations
    backtrace = (backtrace||[]).map { |line| Location.parse line }
    backtrace.each_cons(2) { |crnt, pred| crnt.pred, pred.succ = pred, crnt }
    backtrace
  end
end
