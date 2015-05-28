require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class Exception < Base
    autoload :TerminalFormatter, File.expand_path('terminal_formatter', __dir__)

    def self.for?(einfo)
      true
    end

    def explanation
      einfo.message
    end
  end
end
