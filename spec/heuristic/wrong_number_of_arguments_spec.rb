require 'heuristic/spec_helper'

RSpec.describe 'heuristics for the WrongNumberOfArguments', heuristic: true do
  def heuristic_class
    ErrorToCommunicate::Heuristic::WrongNumberOfArguments
  end

  describe '.for?' do
    it 'is true when given an MRI style wrong number of arguments message' do
      is_for! ArgumentError.new "wrong number of arguments (1 for 0)"
    end

    it 'is true when given an RBX style wrong number of arguments message' do
      is_for! ArgumentError.new "method 'a': given 1, expected 0"
    end

    it 'is true when given an JRuby style wrong number of arguments message' do
      is_for! ArgumentError.new "wrong number of arguments calling `a` (1 for 0)"
    end

    it 'is true when given an MRI style wrong number of arguments message' do
      is_for! ArgumentError.new "wrong number of arguments (1 for 0)"
    end

    it 'is false for ArgumentErrors that are not "wrong number of arguments"' do
      is_not_for!  ArgumentError.new "Some other kind of ArgumentError"
    end

    it 'is false when the message is contained within some other message (not overeager)' do
      is_not_for! RSpec::Expectations::ExpectationNotMetError.new(<<-MESSAGE)
       expected: "wrong number of arguments (1 for 0) (ArgumentError)"
            got: "Wrong number of arguments"

            (compared using ==)
      MESSAGE
    end
  end

  describe 'parse' do
    let(:mri_message) { "wrong number of arguments (1 for 0)" }
    let(:mri_parsed)  { heuristic_for message: mri_message }

    let(:rbx_message) { "method 'a': given 1, expected 0" }
    let(:rbx_parsed)  { heuristic_for message: rbx_message }

    let(:jruby_message) { "wrong number of arguments calling `a` (1 for 0)" }
    let(:jruby_parsed)  { heuristic_for message: "wrong number of arguments calling `a` (1 for 0)" }

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
