require 'spec_helper'
require 'error_to_communicate/parse/backtrace'

RSpec.describe 'parsing an ArgumentError' do
  let :exception do
    FakeException.new(
      backtrace_locations: [
        { lineno:        111,
          label:         'block in method1',
          base_label:    'method1',
          path:          'path/1.rb',
          absolute_path: '/Users/someone/path/1.rb',
        },
        { lineno:        222,
          label:         'method2',
          base_label:    'method2',
          path:          'path/2.rb',
          absolute_path: '/Users/someone/path/2.rb',
        },
        { lineno:        333,
          label:         'method3',
          base_label:    'method3',
          path:          'path/3.rb',
          absolute_path: '/Users/someone/path/3.rb',
        }
      ],
    )
  end

  def parse(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::Parse::Backtrace.parse(exception)
  end


  it 'records the absolute filepath, linenum, and methodname of each backtrace location' do
    locations = parse exception
    expect(locations.map &:filepath).to eq [
      '/Users/someone/path/1.rb',
      '/Users/someone/path/2.rb',
      '/Users/someone/path/3.rb',
    ]
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
end
