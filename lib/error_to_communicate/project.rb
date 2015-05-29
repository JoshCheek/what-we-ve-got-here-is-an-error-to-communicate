module ErrorToCommunicate
  class Project
    def self.find_rubygems_dir(loaded_features)
      dir = loaded_features.grep(/\/rubygems\/specification.rb/).first
      dir && File.dirname(dir)
    end

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
