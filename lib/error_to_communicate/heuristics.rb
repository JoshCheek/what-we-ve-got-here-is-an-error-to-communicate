require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate
  module Heuristics
    def self.filename_for(const_name)
      const_name.to_s
                .gsub(/([[:lower:]])([[:upper:]])/, '\\1_\\2')     # abCd   -> ab_Cd
                .gsub(/([[:upper:]])(Error|Exception)/, '\\1_\\2') # AError -> A_Error
                .downcase
    end

    def self.const_missing(name)
      path = "error_to_communicate/heuristics/#{filename_for name}/autoload"

      required = false
      begin
        require path
        required = true
      rescue LoadError
      end
      required || super

      if constants.include?(name)
        const_get name
      else
        raise NameError, "Expected #{path.inspect} to define #{self}::#{name}, but it did not."
      end
    end
  end
end
