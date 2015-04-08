require 'parse/spec_helper'
require 'error_to_communicate/parse/no_method_error'

RSpec.describe 'parsing a NoMethodError', parse: true do
  parse = lambda do |exception|
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError.parse(exception)
  end

  define_method :parse, &parse

  it_behaves_like 'an exception parser', parse, "undefined method `<' for nil:NilClass"

  def extracts_method_name!(expected, message)
    actual = WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError.extract_method_name(message)
    expect(actual).to eq expected
  end

  it 'extracts the name of the method that was called' do
    extracts_method_name! '<', "undefined method `<' for nil:NilClass"
  end
end
