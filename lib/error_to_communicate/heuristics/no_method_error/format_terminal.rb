class ErrorToCommunicate::Heuristics::NoMethodError::FormatTerminal
  attr_accessor :einfo, :heuristic, :theme, :format_code

  def initialize(attributes)
    self.heuristic   = attributes.fetch :heuristic
    self.theme       = attributes.fetch :theme
    self.einfo       = attributes.fetch :einfo
    self.format_code = attributes.fetch :format_code
  end

  def header
    [ "#{theme.white}#{einfo.classname} | "\
      "#{theme.bri_red}#{heuristic.explanation} "\
      "#{theme.none}\n"
    ]
  end

  def helpful_info
    [ format_code.call(location:   einfo.backtrace[0],
                       highlight:  einfo.backtrace[0].label,
                       context:    -5..5,
                       message:    "#{heuristic.undefined_method_name} is undefined",
                       emphasisis: :code)
    ]
  end
end
