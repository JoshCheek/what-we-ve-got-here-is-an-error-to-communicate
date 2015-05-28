require 'heuristics/spec_helper'

RSpec.describe 'Heuristic for a NoMethodError', heuristic: true do
  def heuristic_class
    ErrorToCommunicate::Heuristics::NoMethodError
  end

  def extracts_method_name!(expected, message)
    heuristic = heuristic_for message: message
    expect(heuristic.undefined_method_name).to eq expected
  end

  it 'is for NoMethodErrors' do
    is_for!     NoMethodError.new('omg')
    is_not_for! Exception.new('omg')
  end

  it 'extracts the name of the method that was called' do
    extracts_method_name! '<', "undefined method `<' for nil:NilClass"
  end
end
