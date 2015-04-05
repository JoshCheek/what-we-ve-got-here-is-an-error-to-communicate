require 'acceptance/spec_helper'

RSpec.describe 'NoMethodError', acceptance: true do
  it 'Prints heuristics' do
    # Given a file that throws an error with two lines in the backtrace
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

    # heuristic:
      # It displays a hlepful message next to the callsite
      expect(stderr).to include 'backtrace4 is undefined'

      # It displays the line of the backtrace with the NoMethodError, and some context around it
      expect(stderr).to include 'def self.backtrace2'
      expect(stderr).to include '  Test.backtrace4'
      expect(stderr).to include 'end'

    # backtrace: It displays each line of the backtrace and includes the code from that line
      expect(stderr).to include 'no_method_error.rb:7'
      expect(stderr).to include 'backtrace4'

      expect(stderr).to include '14'
      expect(stderr).to include 'backtrace2'
  end
end