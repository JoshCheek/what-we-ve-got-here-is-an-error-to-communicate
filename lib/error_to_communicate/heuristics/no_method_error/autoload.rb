require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class NoMethodError < Base
    autoload :TerminalFormatter, File.expand_path('terminal_formatter', __dir__)

    def self.for?(einfo)
      einfo.classname == 'NoMethodError'
    end

    def explanation
      einfo.message[/^[^\(]*/].strip
    end

    def undefined_method_name
      words = einfo.message.split(/\s+/)
      words[2][1...-1]
    end
  end
end
