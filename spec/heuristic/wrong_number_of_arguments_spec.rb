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

  let(:message_2_for_3) { "wrong number of arguments calling `a` (1 for 0)" }

  it 'shows the first two lines of the backtrace' do
    heuristic = heuristic_for message: message_2_for_3, backtrace: [
      "/a:1:in `a'", "/b:2:in `b'", "/c:3:in `c'"
    ]
    _heuristic, codeblocks = heuristic.semantic_info
    paths = codeblocks.map { |_code, attrs| attrs[:location].path.to_s }
    expect(paths).to eq ['/a', '/b']
  end

  it 'only shows one code sample when there is only one line in the backtrace, with context before and after, and no message, and highlights its label on the offchance that this is the right thing to do' do
    heuristic = heuristic_for message: message_2_for_3, backtrace: ["/a:1:in `b'"]
    _heuristic, *codeblocks = heuristic.semantic_info
    expect(codeblocks.length).to eq 1
    ((_code, attrs)) = codeblocks
    expect(attrs).to eq highlight: 'b',
                        context:   (-5..5),
                        emphasis: :code,
                        location: ErrorToCommunicate::ExceptionInfo::Location.new(
                                    path: '/a', linenum: 1, label: 'b'
                                  )
  end

  it 'shrugs "sorry" when there are no lines in the backtrace' do
    heuristic = heuristic_for message: message_2_for_3, backtrace: []
    expect(heuristic.semantic_info).to eq [:context, "Couldn\'t find anything interesting ¯\_(ツ)_/¯\n"]
  end

  describe 'When there are at least two lines in the backtrace' do
    attr_reader :code1, :code2
    before :each do
      heuristic = heuristic_for message: message_2_for_3, backtrace: ["/a:1:in `a'", "/b:2:in `b'", "/b:2:in `b'"]
      heuristic, ((name1, @code1), (name2, @code2), *rest) = heuristic.semantic_info
      expect(heuristic).to eq :heuristic
      expect(name1).to eq :code
      expect(name2).to eq :code
      expect(rest).to be_empty
    end

    describe 'the first line' do
      it 'has a context of 0..5 (b/c it\'s a method definition, so no point in seeing preceding context)'
      it 'declares the number of expected args as the message'
      it 'emphasizes the code'
      it 'highlights it\'s own label (as it is the method name)'
    end

    describe 'the second line' do
      it 'has a context of -5..5 so we can see what we were thinking when we called it'
      it 'declares the number of sent args as the message'
      it 'emphasizes the code'
      it 'highlights the first line\'s label (because that\'s the method call)'
    end

  end
end
