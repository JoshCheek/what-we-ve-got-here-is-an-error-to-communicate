class FakeException
  attr_reader :message, :backtrace

  def initialize(attributes)
    @message   = attributes.fetch :message, 'default message'
    @backtrace = attributes.fetch(:backtrace, [])
  end

  def exception
    self
  end
end
