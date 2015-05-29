module ErrorToCommunicate
  class Project
    attr_reader :root, :rubygems_dir, :loaded_features

    def initialize(attributes)
      attributes = attributes.dup
      self.root            = extract attributes, :project_root
      self.loaded_features = extract attributes, :loaded_features
      self.rubygems_dir    = extract attributes, :rubygems_dir, :find_rubygems_dir
      raise "Unexpected attributes: #{attributes.keys}" if attributes.any?
    end

    def rubygems?
      !rubygems_dir
    end

    private

    attr_writer :root, :rubygems_dir, :loaded_features

    def extract(attributes, key, set_default=nil)
      attributes.delete(key) || __send__(set_default)
    end

    def find_rubygems_dir
      rubygems_dir = loaded_features.grep(/\/rubygems\/specification.rb/).first
      rubygems_dir && File.dirname(rubygems_dir)
    end
  end
end
