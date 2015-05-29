require 'heuristic/spec_helper'

RSpec.describe 'Heuristic for a NoMethodError', heuristic: true do
  def heuristic_class
    ErrorToCommunicate::Heuristic::NoMethodError
  end

  def extracts_method_name!(expected, message)
    heuristic = heuristic_for message: message
    expect(heuristic.undefined_method_name).to eq expected
  end

  it 'is for NoMethodErrors and NameErrors where it can parse out the missing name' do
    is_for!     NoMethodError.new("undefined method `backtrace4' for Test:Module")
    is_for!     NameError.new("undefined local variable or method `backtrace4' for Test:Module")
    is_not_for! NoMethodError.new("abc")
    is_not_for! NameError.new("abc")
    is_not_for! Exception.new("undefined local variable or method `backtrace4' for Test:Module") # do we actually want to assert this?
  end

  it 'extracts the name of the method that was called' do
    extracts_method_name! '<', "undefined method `<' for nil:NilClass"
    extracts_method_name! "ab `c' d", "undefined method `ab `c' d' for main:Object"
  end
end
