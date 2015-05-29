require 'pathname'
require 'error_to_communicate/version'
require 'error_to_communicate/theme'
require 'error_to_communicate/exception_info'

module ErrorToCommunicate
  autoload :FormatTerminal, 'error_to_communicate/format_terminal'

  class Config
    # Freezing this to encourage duping it rather than modifying the global default.
    # This implies we should provide a way to add/remove heuristics on the config itself.
    require 'error_to_communicate/heuristic/wrong_number_of_arguments'
    require 'error_to_communicate/heuristic/no_method_error'
    require 'error_to_communicate/heuristic/load_error'
    require 'error_to_communicate/heuristic/exception'
    DEFAULT_HEURISTICS = [
      Heuristic::WrongNumberOfArguments,
      Heuristic::NoMethodError,
      Heuristic::LoadError,
      Heuristic::Exception,
    ].freeze

    # Should maybe also be an array, b/c there's no great way to add a proc to the blacklist,
    # right now, it would have to check it's thing and then call the next one
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
      format_with.call theme: theme, heuristic: heuristic, cwd: Pathname.new(cwd)
    end
  end
end
