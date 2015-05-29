class ErrorToCommunicate::Heuristics::WrongNumberOfArguments::TerminalFormatter
  attr_accessor :heuristic, :theme, :format_code

  def initialize(attributes)
    self.heuristic   = attributes.fetch :heuristic
    self.theme       = attributes.fetch :theme
    self.format_code = attributes.fetch :format_code
  end

  # Really, it seems like the heuristics job to know this, not the formatter's
  def helpful_info
    [ format_code.call(location:   heuristic.backtrace[0],
                       highlight:  heuristic.backtrace[0].label,
                       context:    0..5,
                       message:    "EXPECTED #{heuristic.num_expected}",
                       emphasisis: :code),

      format_code.call(location:   heuristic.backtrace[1],
                       highlight:  heuristic.backtrace[0].label,
                       context:    -5..5,
                       message:    "SENT #{heuristic.num_received}",
                       emphasisis: :code)
    ]
  end
end
