require 'error_to_communicate/version'
require 'error_to_communicate/theme'
require 'error_to_communicate/heuristics'
require 'error_to_communicate/exception_info'

module ErrorToCommunicate
  autoload :FormatTerminal, 'error_to_communicate/format_terminal'

  class Config
    DEFAULT_HEURISTICS = [
      Heuristics::WrongNumberOfArguments,
      Heuristics::NoMethodError,
      Heuristics::Exception,
    ].freeze # dup it, don't modify the real one

    DEFAULT_BLACKLIST = lambda do |einfo|
      einfo.classname == 'SystemExit'
    end

    def self.default
      @default ||= new
    end

    attr_accessor :heuristics, :blacklist, :theme, :format_with, :catchall_heuristic

    def initialize(options={})
      self.heuristics  = options.fetch(:heuristics)  { DEFAULT_HEURISTICS }
      self.blacklist   = options.fetch(:blacklist)   { DEFAULT_BLACKLIST }
      self.theme       = options.fetch(:theme)       { Theme.new } # this is still really fkn rough
      self.format_with = options.fetch(:format_with) { FormatTerminal }
    end

    def accept?(exception)
      return false unless ExceptionInfo.parseable? exception
      einfo = ExceptionInfo.parse(exception)
      !blacklist.call(einfo) && !!heuristics.find { |h| h.for? einfo }
    end

    def heuristic_for(exception)
      accept?(exception) || raise(ArgumentError, "Asked for a heuristic on an object we don't accept: #{exception.inspect}")
      einfo = ExceptionInfo.parse(exception)
      heuristics.find { |heuristic| heuristic.for? einfo }.new(einfo)
    end

    def format(heuristic, cwd)
      require 'error_to_communicate/format_terminal/presenter'
      presenter = FormatTerminal::Presenter.new theme: theme, cwd: cwd
      format_with.call theme:               theme,
                       einfo:               heuristic.exception_info,
                       heuristic_formatter: heuristic.format_for_terminal(theme, presenter),
                       presenter:           presenter
    end
  end
end
