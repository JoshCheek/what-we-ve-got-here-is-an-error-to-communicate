require 'spec_helper'

RSpec.shared_examples 'an exception parser' do |attributes|
  let(:message) { attributes.fetch :sample_message }

  let :exception do
    FakeException.new message:   message,
                      backtrace: ["/Users/someone/a/b/c.rb:123:in `some_method_name'"]
  end

  it 'records the exception, class name, and explanation comes from the message' do
    info = parse exception
    expect(info.exception  ).to equal exception
    expect(info.classname  ).to eq 'FakeException'
    expect(info.explanation).to eq message
  end

  it 'records the backtrace locations' do
    info = parse exception
    expect(info.backtrace.map &:linenum).to eq [123]
  end
end
