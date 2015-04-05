require 'acceptance/spec_helper'

RSpec.context 'ArgumentError', acceptance: true do
  it 'Prints heuristics' do
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
      expect(stderr).to include 'wrong number of arguments'
      expect(stderr).to include '(expected 0, sent 1)'

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
