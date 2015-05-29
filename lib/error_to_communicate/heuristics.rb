require 'error_to_communicate/heuristics/base'

module ErrorToCommunicate
  module Heuristics
    def self.filename_for(subclass_or_name)
      subclass_or_name
        .to_s
        .gsub(/([[:lower:]])([[:upper:]])/, '\\1_\\2')     # abCd   -> ab_Cd
        .gsub(/([[:upper:]])(Error|Exception)/, '\\1_\\2') # AError -> A_Error
        .downcase
    end

    def self.filepath_for(subclass_or_name, *path)
      File.join 'error_to_communicate', 'heuristics', filename_for(subclass_or_name), *path
    end

    # TODO: refactor
    def self.const_missing(name)
      path = filepath_for name, 'autoload'
      required = false
      begin
        require path
        required = true
      rescue LoadError => err
        raise err unless err.message.include? path # the file we're loading can also raise load errors
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
