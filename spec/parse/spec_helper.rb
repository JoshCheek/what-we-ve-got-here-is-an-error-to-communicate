require 'spec_helper'

RSpec.shared_examples 'an exception parser' do |parse|
  let :exception do
    FakeException.new(
      message:     'some message',
      backtrace_locations: [
        { lineno:        123,
          label:         'some_method_name',
          base_label:    'block in some_method_name',
          path:          'a/b/c.rb',
          absolute_path: '/Users/someone/a/b/c.rb',
        }
      ],
    )
  end

  it 'records the exception, class name, and explanation comes from the message' do
    info = parse.call exception
    expect(info.exception  ).to equal exception
    expect(info.classname  ).to eq 'FakeException'
    expect(info.explanation).to eq 'some message'
  end

  it 'records the backtrace locations' do
    info = parse.call exception
    expect(info.backtrace.map &:linenum).to eq [123]
  end
end
