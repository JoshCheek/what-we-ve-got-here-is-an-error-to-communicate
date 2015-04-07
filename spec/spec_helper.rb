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

RSpec.configure do |config|
  # Stop testing after first failure
  config.fail_fast = true

  # Don't define should/describe on Object
  config.disable_monkey_patching!
end
