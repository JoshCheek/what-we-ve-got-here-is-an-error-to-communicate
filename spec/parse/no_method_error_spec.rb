require 'spec_helper'
require 'error_to_communicate/parse/no_method_error'

RSpec.describe 'parsing a NoMethodError' do
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

  def parse(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError
      .parse(exception)
  end

  it 'records the exception, class name, and explanation comes from the message' do
    info = parse exception
    expect(info.exception  ).to equal exception
    expect(info.classname  ).to eq 'FakeException'
    expect(info.explanation).to eq 'some message'
  end

  it 'records the backtrace locations' do
    info = parse exception
    expect(info.backtrace.map &:linenum).to eq [123]
  end


  # Going to wait on implementing these as they may not be correct,
  # e.g. anyone can raise an argument error for any reason.
  it 'extracts the name of the method that was called'
end
