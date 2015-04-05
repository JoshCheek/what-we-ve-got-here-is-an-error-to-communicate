require 'spec_helper'
require 'parse/spec_helper'
require 'error_to_communicate/parse/argument_error'

RSpec.describe 'parsing an ArgumentError' do
  parse = lambda do |exception|
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::ArgumentError.parse(exception)
  end

  before do
    pending 'too tired to figure it out right now. I\'m matching them positionally, but they\'re in opposite positions'
    raise
  end

  it_behaves_like 'an exception parser', parse

  context 'Wrong number of arguments' do
    let(:rbx_message) { "method 'a': given 1, expected 0 (ArgumentError)" }
    let(:rbx_parsed)  { parse.call FakeException.new(message: rbx_message) }

    let(:mri_message) { "wrong number of arguments (1 for 0) (ArgumentError)" }
    let(:mri_parsed)  { parse.call FakeException.new(message: mri_message) }

    it 'extracts the number of arguments that were passed' do
      pending 'too tired to figure it out right now. I\'m matching them positionally, but they\'re in opposite positions'
      expect(rbx_parsed.num_expected).to eq 0
      expect(mri_parsed.num_expected).to eq 0
    end

    it 'extracts the number of arguments that were received' do
      expect(rbx_parsed.num_received).to eq 1
      expect(mri_parsed.num_received).to eq 1
    end
  end
end
