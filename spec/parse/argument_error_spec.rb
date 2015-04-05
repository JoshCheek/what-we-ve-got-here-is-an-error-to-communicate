require 'parse/spec_helper'
require 'error_to_communicate/parse/argument_error'

RSpec.describe 'parsing an ArgumentError' do
  parse = lambda do |exception|
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::ArgumentError.parse(exception)
  end

  it_behaves_like 'an exception parser', parse

  # Going to wait on implementing these as they may not be correct,
  # e.g. anyone can raise an argument error for any reason.
  it 'extracts the number of arguments that were passed'
  it 'extracts the number of arguments that were received'
end
