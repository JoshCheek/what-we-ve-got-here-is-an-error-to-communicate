class ErrorToCommunicate::Heuristics::NoMethodError::FormatTerminal
  attr_accessor :info, :cwd, :heuristic, :theme, :presenter

  def initialize(attributes)
    self.heuristic = attributes.fetch :heuristic
    self.theme     = attributes.fetch :theme
    self.info      = attributes.fetch :exception_info
    self.cwd       = attributes.fetch :cwd
    self.presenter = attributes.fetch :presenter
  end

  def header
    [ "#{theme.white}#{info.classname} | "\
      "#{theme.bri_red}#{heuristic.explanation} "\
      "#{theme.none}\n"
    ]
  end

  def helpful_info
    [presenter.display_location(location:   info.backtrace[0],
                                highlight:  info.backtrace[0].label,
                                context:    -5..5,
                                message:    "#{heuristic.undefined_method_name} is undefined",
                                emphasisis: :code,
                                cwd:        cwd)
    ]
  end
end
