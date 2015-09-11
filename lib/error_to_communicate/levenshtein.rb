module ErrorToCommunicate
  class Levenshtein
    def self.call(target, actual)
      new(target, actual).distance
    end

    attr_accessor :target, :actual, :memoized
    def initialize(target, actual)
      self.target   = target
      self.actual   = actual
      self.memoized = {}
    end

    def distance
      @distance ||= call target.length, actual.length
    end

    def call(target_length, actual_length)
      memoized[[target_length, actual_length]] ||=
        if target_length.zero?
          actual_length
        elsif actual_length.zero?
          target_length
        elsif target[target_length - 1] == actual[actual_length - 1]
          call(target_length - 1, actual_length - 1)
        else
          [ call(target_length    , actual_length - 1),
            call(target_length - 1, actual_length    ),
            call(target_length - 1, actual_length - 1),
          ].min + 1
        end
    end
  end
end
