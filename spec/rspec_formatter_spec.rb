require 'stringio'
require 'spec_helper'

RSpec.describe ErrorToCommunicate::RSpecFormatter, formatter: true do
  def formatter_for(attributes)
    outstream = attributes.fetch(:outstream) { StringIO.new }
    described_class.new(outstream)
  end

  def new_formatter
    formatter_for({})
  end

  # The interfaces mocked out here were taken from RSpec 3.2.2
  # They're all private, but IDK how else to test it :/
  def run_specs_against(formatter, *describe_args, &describe_block)
    configuration = RSpec::Core::Configuration.new
    reporter      = RSpec::Core::Reporter.new(configuration)

    # instead of hard-coding this, can we get the notifications its actually registered for?
    reporter.register_listener formatter, :dump_failures

    group = RSpec::Core::ExampleGroup.describe(*describe_args, &describe_block)

    # decouple from example filters on the global config
    class << group
      alias filtered_examples examples
      def fail_fast?() false end
    end

    group.run(reporter)
    reporter.finish
  end

  def this_line_of_code
    file, line = caller[0].split(":").take(2)
    File.read(file).lines[line.to_i].strip
  end

  def get_printed(formatter)
    # FIXME: hack until we get it respecting colour on/off
    formatter.output.string.gsub(/\e\[\d+(;\d+)*?m/, '')
  end

  # relevant, b/c then I don't have to test the side effects of this backtrace formatter vs that one
  it 'defaults to using the global backtrace formatter' do
    expect(new_formatter.backtrace_formatter)
      .to equal RSpec.configuration.backtrace_formatter
  end

  it 'uses our lib to print the details of failing examples.' do
    formatter    = new_formatter
    failure_line = this_line_of_code
    run_specs_against formatter do
      example('will fail') { fail }
    end
    expect(get_printed formatter).to include failure_line

    formatter    = new_formatter
    success_line = this_line_of_code
    run_specs_against formatter do
      example('will pass') { }
    end
    expect(get_printed formatter).to_not include success_line
  end

  it 'numbers the failure and prints the failure descriptions' do
    formatter = new_formatter
    run_specs_against formatter, 'GroupName' do
      example('hello') { fail }
      example('world') { fail }
    end
    expect(get_printed formatter).to match /1\)\s*GroupName\s*hello/
    expect(get_printed formatter).to match /2\)\s*GroupName\s*world/
  end

  it 'respects the backtrace formatter'
    # check for lib/rspec/core in printed output

  it 'respects colour enabling/disabling'
    # allow(RSpec.configuration).to receive(:color_enabled?) { true }

  it 'prints to RSpec\s output stream'
end
