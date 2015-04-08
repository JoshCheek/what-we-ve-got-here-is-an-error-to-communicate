require 'stringio'
require 'spec_helper'

RSpec.describe ErrorToCommunicate::RSpecFormatter, formatter: true do
  def formatter_for(attributes)
    outstream = attributes.fetch(:outstream) { StringIO.new }
    described_class.new(outstream)
  end

  let(:formatter) { formatter_for({}) }

  # relevant, b/c then I don't have to test the side effects of this backtrace formatter vs that one
  it 'defaults to using the global backtrace formatter' do
    expect(formatter.backtrace_formatter)
      .to equal RSpec.configuration.backtrace_formatter
  end

  # this shit is all private, but IDK how else to test it :/
  it 'uses our lib to print the details of failing examples.' do
    configuration = RSpec::Core::Configuration.new
    reporter      = RSpec::Core::Reporter.new(configuration)
    reporter.register_listener formatter, :dump_failures
    something_only_we_would_print = File.read(__FILE__).lines[__LINE__ - 1].strip

    RSpec::Core::ExampleGroup.describe {
      example {      }
      example { fail }

      # decoupling from global example filter
      class << self
        alias filtered_examples examples
      end
    }.run(reporter)
    reporter.finish
    printed = formatter.output.string.gsub(/\e\[\d+(;\d+)*?m/, '') # FIXME: hack until we get it respecting colour on/off
    expect(printed).to include something_only_we_would_print
  end

  it 'includes the failure number and description'

  it 'respects the backtrace formatter'
    # check for lib/rspec/core in printed output

  it 'respects colour enabling/disabling'
    # allow(RSpec.configuration).to receive(:color_enabled?) { true }

  it 'prints to RSpec\s output stream'
end
