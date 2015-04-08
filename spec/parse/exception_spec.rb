require 'parse/spec_helper'
require 'error_to_communicate/parse/exception'

RSpec.describe 'parsing an Exception' do
  def parse(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::Exception.parse(exception)
  end

  it_behaves_like 'an exception parser', sample_message: 'literally anything'

  # Going to wait on implementing these as they may not be correct,
  # e.g. anyone can raise an argument error for any reason.
  it 'extracts the name of the method that was called'
end
