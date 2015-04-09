require 'parse/spec_helper'
require 'error_to_communicate/parse/exception'

RSpec.describe 'parsing an Exception', parse: true do
  def parse(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::Exception.parse(exception)
  end

  it_behaves_like 'an exception parser', sample_message: 'literally anything'
end
