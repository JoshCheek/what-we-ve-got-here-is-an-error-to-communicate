require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class Exception < Base
    def self.for?(einfo)
      true
    end

    def explanation
      exception_info.message
    end
  end
end
