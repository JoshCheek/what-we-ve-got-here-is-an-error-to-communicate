require 'haiti/command_line_helpers'

root_dir            = File.expand_path '../..', __FILE__
lib_dir             = File.join(root_dir, 'lib')
proving_grounds_dir = File.join(root_dir, 'proving_grounds')

Haiti.configure do |config|
  config.proving_grounds_dir = proving_grounds_dir
end
RSpec.configure do |config|
  config.disable_monkey_patching = true
end

describe 'Acceptace test' do
  include Haiti::CommandLineHelpers
  before { make_proving_grounds }

  define_method :ruby do |filename|
    execute "ruby -I #{lib_dir} #{filename}", '', ENV
  end

  def strip_color(string)
    string.gsub(/\e\[\d+(;\d+)*?m/, '')
  end

  example 'Does nothing when there is no error' do
    # Given a file that doesn't error
    write_file 'no_error.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      print "hello, world"
    BODY

    # No exception is printed
    invocation = ruby 'no_error.rb'

    # It exits with 0
    expect(invocation.stderr).to     eq ''
    expect(invocation.stdout).to     eq 'hello, world'
    expect(invocation.exitstatus).to eq 0
  end

  example 'Prints heuristics for an Argument Error' do
    # Given a file with three lines in the backtrace that explodes on the third
    write_file 'argument_error.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      module Test
        def self.backtrace1
        end

        def self.backtrace2
          backtrace1 123
        end
      end

      Test.backtrace2
    BODY

    invocation = ruby 'argument_error.rb'
    stderr = strip_color invocation.stderr

    # sanity
      expect(invocation.stdout).to     eq ''
      expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and prints the reworded message
      expect(stderr).to include 'ArgumentError'
      expect(stderr).to include 'wrong number of arguments (expected 0, sent 1)'

    # heuristic:
      # It displays name of the file with the line number of the error
      expect(stderr).to include 'argument_error.rb:3'

      # It displays the most recent line of code with some context
      expect(stderr).to include 'self.backtrace1'
      expect(stderr).to include 'end'

      # It displays the second most recent line of the backtrace with some context around it
      expect(stderr).to include 'def self.backtrace2'
      expect(stderr).to include '  backtrace1 123'
      expect(stderr).to include 'end'

    # backtrace: displays each line of the backtrace with the code from that line
      expect(stderr).to include 'argument_error.rb:3'
      expect(stderr).to include 'def self.backtrace1'

      expect(stderr).to include 'argument_error.rb:7'
      expect(stderr).to include 'def self.backtrace2'

      expect(stderr).to include 'argument_error.rb:11'
      expect(stderr).to include 'Test.backtrace2'
  end
end
