require 'error_to_communicate/levenshtein'

RSpec.describe ErrorToCommunicate::Levenshtein do
  def assert_distance(distance, target, actual)
    expect(described_class.call target, actual).to eq distance
  end

  specify 'count one distance for each substitution' do
    assert_distance 1, "kitten", "sitten" # "s" for "k"
    assert_distance 1, "sitten", "sittin" # "i" for "e"
    assert_distance 2, "sitten", "sitxin" # "i" for "e", and "x" for "t"
  end

  example 'count one distance for each addition' do
    assert_distance 1, "sittin", "sitting" # "g"
    assert_distance 2, "sitin",  "sitting"  # "t", and "g"
    assert_distance 2, "cat",    "catch"    # "ch"
  end

  example 'count one distance for each deletion' do
    assert_distance 1, "sitting", "sittin" # "g"
    assert_distance 2, "sitting", "sitin"  # "t", and "g"
    assert_distance 2, "catch",   "cat"    # "ch"
  end

  example 'add the various numbers' do
    # add "a" at beginning
    # delete "h" from end
    # swap "X" to "d"
    assert_distance 3, "abcdefg", "bcXefgh"
  end

  describe 'some edge cases' do
    [ ['--a', 'a', 2],
      ['a', '--a', 2],
      ['-a-', 'a', 2],
      ['a', '-a-', 2],
      ['---', 'a', 3],
      ['a', '---', 3],
      ['aaa', 'bbb', 3],
      ['bbb', 'aaa', 3],
    ].each do |s1, s2, distance|
      example "distance(#{s1.inspect}, #{s2.inspect}) # => #{distance.inspect}" do
        assert_distance distance, s1, s2
      end
    end
  end

  specify 'it is not crazy stupid slow' do
    skip 'find a better algorithm'
    # When comparing "aaa", "bbb",
    # This algorithm compares 94 pairs of strings.
    # When those pairs are uniqued, there are only 16 left,
    # so it is doing 78 redundant steps.
    #
    # At length 4 ("aaaa", "bbbb"), it does 481 comparisons instead of 25
    # At length 5, 2524 instead of 36
    # At length 10, 12_146_179 instead of 121, and it took 52.585554 seconds
    #
    # This is the code I used to count them:
    #
    # in algorithm:
    #   pair = [target[0...target_length], actual[0...actual_length]]
    #   $all[pair] += 1
    #
    # in test
    #   $all = Hash.new 0
    #   ...
    #   p $all.values.inject(0, :+)
    #   p $all.size
    n = 10
    start = Time.now
    assert_distance n, "a"*n, "b"*n
    time = Time.now - start
    assert time < 1
  end
end
