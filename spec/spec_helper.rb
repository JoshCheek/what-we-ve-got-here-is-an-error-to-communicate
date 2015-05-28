class FakeException
  attr_reader :message, :backtrace

  def initialize(attributes={})
    @message   = attributes.fetch :message, 'default message'
    @backtrace = attributes.fetch(:backtrace, [])
  end

  def exception
    self
  end
end

module SpecHelpers
  def einfo_for(exception)
    ErrorToCommunicate::ExceptionInfo.parse exception
  end

  def trap_warnings
    initial_stderr = $stderr
    mock_stderr    = StringIO.new
    $stderr        = mock_stderr
    yield
  ensure
    $stderr  = initial_stderr
    warnings = mock_stderr.string
    return warnings unless $! # don't swallow exceptions
  end
end


RSpec.configure do |config|
  config.include SpecHelpers

  # Stop testing after first failure
  config.fail_fast = true

  # Don't define should/describe on Object
  config.disable_monkey_patching!
end
