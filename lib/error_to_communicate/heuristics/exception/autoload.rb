require 'error_to_communicate/heuristics/base'
module ErrorToCommunicate::Heuristics
  class Exception < Base
    require 'error_to_communicate/heuristics/exception/format_terminal'

    def self.for?(einfo)
      true
    end

    def explanation
      einfo.message
    end
  end
end
