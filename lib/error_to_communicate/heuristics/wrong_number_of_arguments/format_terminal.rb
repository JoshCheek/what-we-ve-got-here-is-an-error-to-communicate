class ErrorToCommunicate::Heuristics::WrongNumberOfArguments::FormatTerminal
  attr_accessor :info, :cwd, :heuristic, :theme, :presenter

  def initialize(attributes)
    self.heuristic = attributes.fetch :heuristic
    self.theme     = attributes.fetch :theme
    self.info      = attributes.fetch :exception_info
    self.cwd       = attributes.fetch :cwd
    self.presenter = attributes.fetch :presenter
  end

  # TODO: give these semantic names
  # ALSO: can we lose the dep on exception info? seems like anything this needs should come from the heuristic
  def header
    [ "#{theme.white}#{info.classname} | "\
      "#{theme.bri_red}#{heuristic.explanation} "\
      "#{theme.dim_red}(expected #{theme.white}#{heuristic.num_expected},"\
      "#{theme.dim_red} sent #{theme.white}#{heuristic.num_received}"\
      "#{theme.dim_red})"\
      "#{theme.none}\n"
    ]
  end

  def helpful_info
    [ presenter.display_location(location:   info.backtrace[0],
                                 highlight:  info.backtrace[0].label,
                                 context:    0..5,
                                 message:    "EXPECTED #{heuristic.num_expected}",
                                 emphasisis: :code,
                                 cwd:        cwd),
      presenter.display_location(location:   info.backtrace[1],
                                 highlight:  info.backtrace[0].label,
                                 context:    -5..5,
                                 message:    "SENT #{heuristic.num_received}",
                                 emphasisis: :code,
                                 cwd:        cwd)
    ]
  end
end
