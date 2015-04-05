require 'acceptance/spec_helper'

RSpec.describe 'Acceptace test', acceptance: true do
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

  example 'Prints heuristics for an ArgumentError' do
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

  example 'Prints heuristics for a NoMethodError' do
    #Given a file that throws an error with two lines in the backtrace
    write_file 'no_method_error.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      module Test
        def self.backtrace1
        end

        def self.backtrace2
          Test.backtrace4
        end

        def self.backtrace3
        end
      end

      Test.backtrace2
    BODY
    invocation = ruby 'no_method_error.rb'
    stderr = strip_color invocation.stderr

    # sanity
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and message
    expect(stderr).to include 'NoMethodError'
    expect(stderr).to include "undefined method `backtrace4'"

    #heuristic:
    #  It displays a message next to the line to communicate that this is where it blew up
    expect(stderr).to include 'backtrace4 is undefined'

    #  It displays the line of the backtrace with the NoMethodError, and context around it
    expect(stderr).to include 'def self.backtrace2'
    expect(stderr).to include '  Test.backtrace4'
    expect(stderr).to include 'end'

    #backtrace:
    #  It displays each line of the backtrace and includes the code from that line
    expect(stderr).to include 'no_method_error.rb:7'
    expect(stderr).to include 'backtrace4'

    expect(stderr).to include '14' #line that invoked the call to the error
    expect(stderr).to include 'backtrace2'
  end
end
