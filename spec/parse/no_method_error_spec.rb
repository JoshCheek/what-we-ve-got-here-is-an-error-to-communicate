require 'parse/spec_helper'
require 'error_to_communicate/parse/no_method_error'

RSpec.describe 'parsing a NoMethodError', parse: true do
  def error_class
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError
  end

  def parse(exception)
    error_class.parse(exception)
  end

  it_behaves_like 'an exception parser', sample_message: "undefined method `<' for nil:NilClass"

  def extracts_method_name!(expected, message)
    actual = error_class.extract_method_name(message)
    expect(actual).to eq expected
  end

  it 'extracts the name of the method that was called' do
    extracts_method_name! '<', "undefined method `<' for nil:NilClass"
  end
end
