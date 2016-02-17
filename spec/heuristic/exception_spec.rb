require 'heuristic/spec_helper'

RSpec.describe 'Heuristic for a Exception', heuristic: true do
  def heuristic_class
    ErrorToCommunicate::Heuristic::Exception
  end

  it 'is for every type of exception (via inheritance)' do
    is_for! RuntimeError.new
    is_for! Exception.new('omg')
  end

  it 'uses the exception message as is explanation' do
    einfo = heuristic_for(message: 'message from exception')
    expect(einfo.explanation).to eq 'message from exception'
  end

  it 'returns the null heuristic on empty backtrace' do
    einfo = heuristic_for(backtrace: [])
    expect(einfo.semantic_info).to eq [:heuristic, [:null]]
  end
end
