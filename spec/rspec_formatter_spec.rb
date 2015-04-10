require 'stringio'
require 'spec_helper'

RSpec.describe ErrorToCommunicate::RSpecFormatter, rspec_formatter: true do
  let(:substring_that_would_only_be_in_full_backtrace) { 'lib/rspec/core' }

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
    # Create the example group
    # define some methods to decouple it from the global test suite
    group = RSpec::Core::ExampleGroup.describe(*describe_args, &describe_block)
    class << group
      alias filtered_examples examples
      def fail_fast?() false end
    end

    # The reporter calls into our formatter
    reporter = RSpec::Core::Reporter.new(RSpec::Core::Configuration.new)

    # Register the formatter for all notifications it would actually receive
    registered_notifications = formatter.class.ancestors.flat_map do |ancestor|
      RSpec::Core::Formatters::Loader.formatters.fetch(ancestor, [])
    end
    registered_notifications.each do |notification|
      reporter.register_listener formatter, notification
    end

    # Fake out the runner
    # ordering comes from: http://rspec.info/documentation/3.2/rspec-core/RSpec/Core/Formatters.html
    reporter.start(expected_example_count=123)
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

  it 'uses our lib to print the details of failing examples.' do
    # does print
    formatter = new_formatter
    context_around_failure = this_line_of_code
    run_specs_against formatter do
      example('will fail') { fail }
    end
    expect(get_printed formatter).to include context_around_failure

    # does not print
    formatter = new_formatter
    context_around_success = this_line_of_code
    run_specs_against formatter do
      example('will pass') { }
    end
    expect(get_printed formatter).to_not include context_around_success
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

  it 'respects the backtrace formatter (ie the --backtrace flag)' do
    # only need to check a failing example to show it uses RSpec's backtrace formatter
    formatter = new_formatter
    run_specs_against(formatter) { example { fail } }
    expect(get_printed formatter)
      .to_not include substring_that_would_only_be_in_full_backtrace
  end

  it 'respects colour enabling/disabling' do
    # https://github.com/rspec/rspec-core/blob/2a07aa92560cf6d4ae73ab04ff3b9b565451e83f/spec/rspec/core/formatters/console_codes_spec.rb#L35
    # allow(RSpec.configuration).to receive(:color_enabled?) { true }
    pending 'We don\'t yet have the ability to turn color printing on/off'
    fail
  end
end
