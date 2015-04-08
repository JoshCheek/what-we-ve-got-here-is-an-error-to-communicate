require 'parse/spec_helper'
require 'error_to_communicate/parse/no_method_error'

RSpec.describe 'parsing a NoMethodError', parse: true do
  parse = lambda do |exception|
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError.parse(exception)
  end

  define_method :parse, &parse

  it_behaves_like 'an exception parser', parse, "undefined method `<' for nil:NilClass"

  def assert_finds_method(method, message)
    exception_info = parse FakeException.new(message: message)
    expect(exception_info.undefined_method_name).to eq method
  end

  it 'extracts the name of the method that was called' do
    assert_finds_method '<', "undefined method `<' for nil:NilClass"
  end
end
