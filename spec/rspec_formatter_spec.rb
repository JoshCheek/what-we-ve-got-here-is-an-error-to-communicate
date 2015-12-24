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
    File.read(file).lines.to_a[line.to_i].strip
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
      example('world') { expect(1).to eq 2 }
    end
    expect(get_printed formatter).to match /1\s*\|\s*GroupName\s*hello/
    expect(get_printed formatter).to match /2\s*\|\s*GroupName\s*world/
  end

  it 'respects colour enabling/disabling' do
    # https://github.com/rspec/rspec-core/blob/2a07aa92560cf6d4ae73ab04ff3b9b565451e83f/spec/rspec/core/formatters/console_codes_spec.rb#L35
    # allow(RSpec.configuration).to receive(:color_enabled?) { true }
    pending 'We don\'t yet have the ability to turn color printing on/off'
    fail
  end


  mock_failure_notification = Struct.new :exception, :formatted_backtrace, :description

  define_method :failure_for do |attrs|
    message   = attrs.fetch :message, "ZOMG!"
    exception = attrs.fetch :exception do
      case attrs.fetch :type, :assertion
      when :assertion
        RSpec::Expectations::ExpectationNotMetError.new message
      when :argument_error
        ArgumentError.new message
      else raise "uhm: #{attrs.inspect}"
      end
    end

    mock_failure_notification.new \
      exception,
      attrs.fetch(:formatted_backtrace) { ["/a:1:in `b'"] },
      attrs.fetch(:description, "default-description")
  end

  context 'when the failure is an error' do
    it 'prints the backtrace, respecting the backtrace formatter (ie the --backtrace flag)' do
      # only need to check a failing example to show it uses RSpec's backtrace formatter
      formatter = new_formatter
      run_specs_against(formatter) { example { fail } }
      expect(get_printed formatter)
        .to_not include substring_that_would_only_be_in_full_backtrace
    end

    specify 'the summary is the failure number and description' do
      config    = ErrorToCommunicate::Config.new
      heuristic = ErrorToCommunicate::Heuristic::RSpecFailure.new \
        config:         ErrorToCommunicate::Config.default,
        failure:        failure_for(description: 'DESC', type: :assertion),
        failure_number: 999,
        binding:        binding
      summaryname, ((columnsname, *columns)) = heuristic.semantic_summary
      expect(summaryname).to eq :summary
      expect(columnsname).to eq :columns
      expect(columns.map &:last).to eq [999, 'DESC']
    end

    specify 'the info is the formatted error message and first line from the backtrace with some context' do
      config    = ErrorToCommunicate::Config.new
      heuristic = ErrorToCommunicate::Heuristic::RSpecFailure.new \
        config:         ErrorToCommunicate::Config.default,
        failure:        failure_for(type: :assertion, message: 'MESSAGE', formatted_backtrace: ["/file:123:in `method'"]),
        failure_number: 999,
        binding:        binding
      heuristicname, ((messagename, message), (codename, codeattrs), *rest) = heuristic.semantic_info
      expect(heuristicname).to eq :heuristic
      expect(messagename  ).to eq :message
      expect(message      ).to eq "MESSAGE\n"
      expect(codename     ).to eq :code
      expect(codeattrs[:location].path.to_s).to eq '/file'
      expect(codeattrs[:context]).to eq (-5..5)
      expect(codeattrs[:emphasis]).to eq :code
      expect(rest).to be_empty
    end

    specify 'it omits the backtrace line, if it DNE' do
      config    = ErrorToCommunicate::Config.new
      heuristic = ErrorToCommunicate::Heuristic::RSpecFailure.new \
        config:         ErrorToCommunicate::Config.default,
        failure_number: 999,
        failure:        failure_for(type: :assertion, message: 'MESSAGE', formatted_backtrace: []),
        binding:        binding
      heuristicname, ((messagename, message), *rest) = heuristic.semantic_info
      expect(heuristicname).to eq :heuristic
      expect(messagename  ).to eq :message
      expect(message      ).to eq "MESSAGE\n"
      expect(rest).to be_empty
    end
  end


  context 'when the failure is an assertion' do
    it 'prints the backtrace, respecting the backtrace formatter (ie the --backtrace flag)' do
      # only need to check a failing example to show it uses RSpec's backtrace formatter
      formatter = new_formatter
      run_specs_against(formatter) { example { expect(1).to eq 2 } }
      expect(get_printed formatter)
        .to_not include substring_that_would_only_be_in_full_backtrace
    end


    specify 'summary is the failure number, description, classname and semantic_explanation from the correct handler' do
      expect_any_instance_of(ErrorToCommunicate::Heuristic::WrongNumberOfArguments)
        .to receive(:semantic_explanation).and_return("SEMANTICEXPLANATION")

      heuristic = ErrorToCommunicate::Heuristic::RSpecFailure.new \
        config:  ErrorToCommunicate::Config.new,
        failure: failure_for(message:     "wrong number of arguments (1 for 0)",
                             description: 'DESC',
                             type:        :argument_error),
        failure_number: 999,
        binding:        binding
      summaryname, ((columnsname, *columns)) = heuristic.semantic_summary
      expect(summaryname).to eq :summary
      expect(columnsname).to eq :columns
      expect(columns.map &:last).to eq [999, 'DESC', 'ArgumentError', 'SEMANTICEXPLANATION']
    end


    it 'delegates the heuristic to the correct handler' do
      expect_any_instance_of(ErrorToCommunicate::Heuristic::WrongNumberOfArguments)
        .to receive(:semantic_info).and_return("SEMANTICINFO")

      heuristic = ErrorToCommunicate::Heuristic::RSpecFailure.new \
        config:         ErrorToCommunicate::Config.new,
        failure:        failure_for(message: "wrong number of arguments (1 for 0)", type: :argument_error),
        failure_number: 999,
        binding:        binding

      expect(heuristic.semantic_info).to eq "SEMANTICINFO"
    end

    it 'provides the bindings needed for some of the advanced analysis' do
      formatter = new_formatter
      context_around_failure = this_line_of_code
      run_specs_against formatter do
        example('suggests better name1') {
          @abc = 123
          @abd.even? # misspelled
        }
        example('suggests better name2') {
          @lol = 123
          @lul.even? # misspelled
        }
      end


      # Sigh the above whitespace is important, or it can pass because the assertion is in the code displayed for context
      # It's stupid, I know
      expect(get_printed formatter).to include "Possible misspelling of `@lol'"
      expect(get_printed formatter).to include "Possible misspelling of `@abc'"
    end
  end

  context 'fixing the message\'s whitespace' do
    def fix_whitespace(str)
      ErrorToCommunicate::Heuristic::RSpecFailure.fix_whitespace str
    end

    it 'removes leading newlines' do
      expect(fix_whitespace "\na").to start_with "a"
      expect(fix_whitespace "\n\n\na").to start_with "a"
    end

    it 'removes all but one trailing newline' do
      expect(fix_whitespace "a\n").to start_with "a\n"
      expect(fix_whitespace "a\n\n").to start_with "a\n"
      expect(fix_whitespace "a\n\n\n").to start_with "a\n"
    end

    it 'adds a trailing newline if its missing' do
      expect(fix_whitespace "a").to start_with "a\n"
    end

    it 'doesn\'t modify the original string' do
      a = "\na"
      b = "a"
      c = "a\n\n"
      d = "a\n"
      [a, b, c, d].each { |s| fix_whitespace s }
      expect(a).to eq "\na"
      expect(b).to eq "a"
      expect(c).to eq "a\n\n"
      expect(d).to eq "a\n"
    end
  end
end
