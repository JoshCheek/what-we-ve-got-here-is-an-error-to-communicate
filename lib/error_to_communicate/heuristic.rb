module ErrorToCommunicate
  class Heuristic
    def self.for?(einfo)
      raise NotImplementedError, "#{self} needs to implement .for? (subclass responsibility)"
    end

    attr_accessor :einfo, :project

    def initialize(einfo)
      self.einfo   = einfo
      self.project = Project.new loaded_features: $LOADED_FEATURES, project_root:   File.expand_path(Dir.pwd)
    end

    def classname
      einfo.classname
    end

    def backtrace
      einfo.backtrace
    end

    def explanation
      einfo.message
    end

    def semantic_explanation
      explanation
    end

    def semantic_summary
      [:summary, [
        [:columns,
          [:classname,   classname],
          [:explanation, semantic_explanation]]]]
    end

    def semantic_info
      [:null]
    end

    def semantic_backtrace
      [:backtrace,
        backtrace.map do |location|
          [:code, {
            location:  location,
            highlight: (location.pred && location.pred.label),
            context:   0..0,
            emphasis:  :path,
          }]
        end
      ]
    end
  end
end
