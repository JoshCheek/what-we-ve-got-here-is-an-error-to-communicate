require 'heuristics/spec_helper'
require 'error_to_communicate/heuristics/no_method_error'

RSpec.describe 'Heuristic for a NoMethodError', heuristic: true do
  def heuristic_class
    WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception
  end

  it 'is for every type of exception (via inheritance)' do
    is_for! RuntimeError.new
    is_for! Exception.new('omg')
  end

  it 'uses the exception message as is explanation' do
    einfo = heuristic_for(message: 'message from exception')
    expect(einfo.explanation).to eq 'message from exception'
  end
end
