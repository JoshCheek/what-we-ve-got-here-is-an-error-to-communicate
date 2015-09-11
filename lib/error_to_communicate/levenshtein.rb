module ErrorToCommunicate
  module Levenshtein
    # When comparing "aaa", "bbb",
    # This algorithm compares 94 pairs of strings.
    # When those pairs are uniqued, there are only 16 left,
    # so it is doing 78 redundant steps.
    #
    # At length 4 ("aaaa", "bbbb"), it does 481 comparisons instead of 25
    # At length 5, 2524 instead of 36
    # At length 10, 12_146_179 instead of 121, and it took 52.585554 seconds
    def self.call(target, actual, target_length=target.length, actual_length=actual.length)
      # base case: empty strings
      return actual_length if target_length.zero?
      return target_length if actual_length.zero?

      # test if last characters of the strings match
      if actual[actual_length-1] == target[target_length-1]
        call target, actual, target_length-1, actual_length-1
      else
        # return minimum of delete char from s, delete char from t, and delete char from both
        [ call(target, actual, target_length    , actual_length - 1),
          call(target, actual, target_length - 1, actual_length    ),
          call(target, actual, target_length - 1, actual_length - 1),
        ].min + 1
      end
    end
  end
end
