require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate::Heuristics
  class WrongNumberOfArguments < Base
    def self.for?(einfo)
      extract_from einfo
    end

    attr_accessor :explanation, :num_expected, :num_received

    def initialize(*)
      super
      self.num_received, self.num_expected = self.class.extract_from(exception_info)
      self.explanation = 'Wrong number of arguments'
    end

    private

    def self.extract_from(einfo)
      case einfo.message
      when /^wrong number of arguments.*?\((\d+) for (\d+)\)$/ # MRI / JRuby
        num_received, num_expected = $1.to_i, $2.to_i
      when /^method '.*?': given (\d+).*? expected (\d+)$/ # RBX
        num_received, num_expected = $1.to_i, $2.to_i
      end
    end
  end
end
