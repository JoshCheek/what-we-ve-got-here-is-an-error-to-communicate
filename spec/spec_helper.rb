class FakeException
  attr_reader :message, :backtrace_locations, :backtrace

  def initialize(attributes)
    @message             = attributes.fetch :message, 'default message'
    @backtrace_locations = attributes.fetch(:backtrace_locations, [])
                                     .map { |bl| BacktraceLocation.new bl }
    @backtrace           = backtrace_locations.map(&:to_s)
  end

  def exception
    self
  end

  class BacktraceLocation
    attr_accessor :lineno, :label, :base_label, :path, :absolute_path
    def initialize(attributes)
      self.lineno        = attributes.fetch :lineno
      self.label         = attributes.fetch :label
      self.base_label    = attributes.fetch :base_label
      self.path          = attributes.fetch :path
      self.absolute_path = attributes.fetch :absolute_path
    end
  end
end
