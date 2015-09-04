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
end
