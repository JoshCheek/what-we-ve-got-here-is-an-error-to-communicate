module ErrorToCommunicate
  module Levenshtein
    def self.call(target, actual, target_length=target.length, actual_length=actual.length)
      # base case: empty strings
      return actual_length if target_length.zero?
      return target_length if actual_length.zero?

      # test if last characters of the strings match
      match = (actual[actual_length-1] == target[target_length-1])
      cost = (match ? 0 : 1)

      # return minimum of delete char from s, delete char from t, and delete char from both
      [ call(target, actual, target_length    , actual_length - 1) + 1,
        call(target, actual, target_length - 1, actual_length    ) + 1,
        call(target, actual, target_length - 1, actual_length - 1) + cost,
      ].min
    end
  end
end
