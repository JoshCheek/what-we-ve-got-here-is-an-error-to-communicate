class ErrorToCommunicate::Heuristics::NoMethodError::FormatTerminal
  attr_accessor :heuristic, :theme, :format_code

  def initialize(attributes)
    self.heuristic   = attributes.fetch :heuristic
    self.theme       = attributes.fetch :theme
    self.format_code = attributes.fetch :format_code
  end

  def header
    [ "#{theme.white}#{heuristic.classname} | "\
      "#{theme.bri_red}#{heuristic.explanation} "\
      "#{theme.none}\n"
    ]
  end

  def helpful_info
    [ format_code.call(location:   heuristic.backtrace[0],
                       highlight:  heuristic.backtrace[0].label,
                       context:    -5..5,
                       message:    "#{heuristic.undefined_method_name} is undefined",
                       emphasisis: :code)
    ]
  end
end
