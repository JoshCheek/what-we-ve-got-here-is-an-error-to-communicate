require 'spec_helper'

RSpec.describe ErrorToCommunicate::RSpecFormatter do
  it 'defaults to using the global backtrace formatter'

  it 'defaults to using the global configuration.color_enabled?'

  it 'uses our lib to print the details of failing examples.'

  it 'includes the failure number and description'

  it 'respects the backtrace formatter'
    # check for lib/rspec/core in printed output

  it 'respects colour enabling/disabling'
    # allow(RSpec.configuration).to receive(:color_enabled?) { true }

  it 'prints to RSpec\s output stream'
end
