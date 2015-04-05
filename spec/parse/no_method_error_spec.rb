require 'parse/spec_helper'
require 'error_to_communicate/parse/no_method_error'

RSpec.describe 'parsing a NoMethodError' do
  parse = lambda do |exception|
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError.parse(exception)
  end

  it_behaves_like 'an exception parser', parse

  # Going to wait on implementing these as they may not be correct,
  # e.g. anyone can raise an argument error for any reason.
  it 'extracts the name of the method that was called'
end
