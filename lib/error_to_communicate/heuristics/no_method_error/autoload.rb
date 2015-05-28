require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class NoMethodError < Base
    require 'error_to_communicate/heuristics/no_method_error/format_terminal'

    def self.for?(einfo)
      einfo.classname == 'NoMethodError'
    end

    def explanation
      exception_info.message[/^[^\(]*/].strip
    end

    def undefined_method_name
      words = exception_info.message.split(/\s+/)
      words[2][1...-1]
    end
  end
end
