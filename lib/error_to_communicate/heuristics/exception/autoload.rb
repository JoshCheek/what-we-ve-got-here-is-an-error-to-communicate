require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class Exception < Base
    autoload :TerminalFormatter, File.expand_path('terminal_formatter', __dir__)

    def self.for?(einfo)
      true
    end

    def helpful_info
      [ [:code, {
          location:   backtrace[0],
          highlight:  backtrace[0].label,
          context:    -5..5,
          emphasisis: :code,
        }]
      ]
    end
  end
end
