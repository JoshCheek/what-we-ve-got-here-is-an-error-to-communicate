require 'spec_helper'
require 'parse/spec_helper'
require 'error_to_communicate/parse/argument_error'

RSpec.describe 'parsing wrong number of arguments' do
  def parse(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::WrongNumberOfArguments.parse(exception)
  end

  it_behaves_like 'an exception parser',
    sample_message:     "wrong number of arguments (1 for 0) (ArgumentError)",
    sample_explanation: "Wrong number of arguments"

  describe 'parse?' do
    def will_parse?(exception)
      WhatWeveGotHereIsAnErrorToCommunicate::Parse::WrongNumberOfArguments.parse?(exception)
    end

    def will_parse!(exception)
      expect(will_parse? exception).to be_truthy
    end

    def wont_parse!(exception)
      expect(will_parse? exception).to be_falsy
    end

    it 'is true when given an MRI style wrong number of arguments message' do
      will_parse! ArgumentError.new "wrong number of arguments (1 for 0)"
    end

    it 'is true when given an RBX style wrong number of arguments message' do
      will_parse! ArgumentError.new "method 'a': given 1, expected 0"
    end

    it 'is true when given an JRuby style wrong number of arguments message' do
      will_parse! ArgumentError.new "wrong number of arguments calling `a` (1 for 0)"
    end

    it 'is true when given an MRI style wrong number of arguments message' do
      will_parse! ArgumentError.new "wrong number of arguments (1 for 0)"
    end

    it 'is false for ArgumentErrors that are not "wrong number of arguments"' do
      wont_parse!  ArgumentError.new "Some other kind of ArgumentError"
    end

    it 'is false when the message is contained within some other message (not overeager)' do
      wont_parse! RSpec::Expectations::ExpectationNotMetError.new(<<-MESSAGE)
       expected: "wrong number of arguments (1 for 0) (ArgumentError)"
            got: "Wrong number of arguments"

            (compared using ==)
      MESSAGE
    end
  end

  describe 'parse' do
    let(:mri_message) { "wrong number of arguments (1 for 0)" }
    let(:mri_parsed)  { parse FakeException.new(message: mri_message) }

    let(:rbx_message) { "method 'a': given 1, expected 0" }
    let(:rbx_parsed)  { parse FakeException.new(message: rbx_message) }

    let(:jruby_message) { "wrong number of arguments calling `a` (1 for 0)" }
    let(:jruby_parsed)  { parse FakeException.new(message: "wrong number of arguments calling `a` (1 for 0)") }

    it 'extracts the number of arguments that were passed' do
      expect(rbx_parsed.num_expected).to eq 0
      expect(mri_parsed.num_expected).to eq 0
    end

    it 'extracts the number of arguments that were received' do
      expect(rbx_parsed.num_received).to eq 1
      expect(mri_parsed.num_received).to eq 1
    end
  end
end
