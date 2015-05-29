class ErrorToCommunicate::Heuristics::WrongNumberOfArguments::TerminalFormatter
  attr_accessor :heuristic, :theme, :format_code

  def initialize(attributes)
    self.heuristic   = attributes.fetch :heuristic
    self.theme       = attributes.fetch :theme
    self.format_code = attributes.fetch :format_code
  end
end
