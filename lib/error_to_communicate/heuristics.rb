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

    def self.const_missing(name)
      path = filepath_for name, 'autoload'
      require path
      return const_get(name) if constants.include?(name)
      raise NameError, "Expected #{path.inspect} to define #{self}::#{name}, but it did not."
    rescue LoadError => err
      super name if err.message.include?(path) # don't swallow load errors raised within the file we're loading
      raise err
    end
  end
end
