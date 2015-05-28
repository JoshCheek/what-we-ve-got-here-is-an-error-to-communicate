require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class Exception < Base
    autoload :FormatTerminal, File.expand_path('format_terminal', __dir__)

    def self.for?(einfo)
      true
    end

    def explanation
      einfo.message
    end
  end
end
