module ErrorToCommunicate
  class Project
    def self.find_rubygems_dir(loaded_features)
      dir = loaded_features.grep(/\/rubygems\/specification.rb/).first
      dir && File.dirname(dir)
    end

    # Things this should possibly deal with?
    # Gemfile?
    #   what gems are in it?
    #   what load paths do these make available?
    # directory structure
    #   what paths are in the lib?
    #   what dirs are in the lib?
    # home_dir
    # available_gems
    # common_gems (maybe they meant to require something from a common gem)
    # $LOAD_PATH
    #   What all is in it? Is a dir misspelled?

    attr_accessor :root

    def initialize(attributes={})
      attributes.each { |name, value| __send__ :"#{name}=", value }
    end

    def rubygems?
      !rubygems_dir
    end

    def loaded_features
      @loaded_features ||= []
    end

    def loaded_features=(loaded_features)
      @loaded_features = loaded_features
    end

    attr_writer :rubygems_dir
    def rubygems_dir
      @rubygems_dir ||= self.class.find_rubygems_dir(loaded_features)
    end

    private

    def extract(attributes, key, set_default=nil)
      attributes.delete(key) || __send__(set_default)
    end
  end
end
