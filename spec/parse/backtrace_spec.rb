require 'spec_helper'
require 'error_to_communicate/parse/backtrace'

RSpec.describe 'parsing an ArgumentError' do
  let :exception do
    FakeException.new backtrace: [
      "file.rb:111:in `method1'",
      "file.rb:222:in `method2'",
      "file.rb:333:in `method3'"
    ]
  end

  def parse(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::Backtrace.parse(exception)
  end

  it 'records the linenum, and methodname of each backtrace location' do
    locations = parse exception
    expect(locations.map &:linenum).to eq [111, 222, 333]
    expect(locations.map &:methodname).to eq %w[method1 method2 method3]
  end

  specify 'the predecessor is the parsed location from the previous index, or nil for the first' do
    l1, l2, l3 = locations = parse(exception)
    expect(locations.map &:pred).to eq [nil, l1, l2]
  end

  specify 'the successor is the parsed locations from the next index, or nil for the last' do
    l1, l2, l3 = locations = parse(exception)
    expect(locations.map &:succ).to eq [l2, l3, nil]
  end

  it 'records the absolute filepath if it can find the file'
  it 'records the relative filepath if it can find the file'
  it 'records the relative filepath if it cannot fild the file'
  it 'does not get confused by numbers in directories, filenames, or method names'
  it 'does not get confused by additional context after the method name'
end
