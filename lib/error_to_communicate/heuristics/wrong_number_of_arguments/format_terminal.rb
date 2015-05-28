class ErrorToCommunicate::Heuristics::WrongNumberOfArguments::FormatTerminal
  attr_accessor :einfo, :heuristic, :theme, :format_code

  def initialize(attributes)
    self.heuristic   = attributes.fetch :heuristic
    self.theme       = attributes.fetch :theme
    self.einfo       = attributes.fetch :einfo
    self.format_code = attributes.fetch :format_code
  end

  # TODO: give these semantic names
  # ALSO: can we lose the dep on exception info? seems like anything this needs should come from the heuristic
  def header
    [ "#{theme.white}#{einfo.classname} | "\
      "#{theme.bri_red}#{heuristic.explanation} "\
      "#{theme.dim_red}(expected #{theme.white}#{heuristic.num_expected},"\
      "#{theme.dim_red} sent #{theme.white}#{heuristic.num_received}"\
      "#{theme.dim_red})"\
      "#{theme.none}\n"
    ]
  end

  def helpful_info
    [ format_code.call(location:   einfo.backtrace[0],
                       highlight:  einfo.backtrace[0].label,
                       context:    0..5,
                       message:    "EXPECTED #{heuristic.num_expected}",
                       emphasisis: :code),

      format_code.call(location:   einfo.backtrace[1],
                       highlight:  einfo.backtrace[0].label,
                       context:    -5..5,
                       message:    "SENT #{heuristic.num_received}",
                       emphasisis: :code)
    ]
  end
end
