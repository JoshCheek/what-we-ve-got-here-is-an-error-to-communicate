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
end
