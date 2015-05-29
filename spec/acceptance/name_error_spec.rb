require 'acceptance/spec_helper'

RSpec.describe 'NameError', acceptance: true do
  it 'Prints heuristics' do
    write_file 'name_error.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      module Test
        def self.backtrace1
        end

        def self.backtrace2
          backtrace4
        end

        def self.backtrace3
        end
      end

      Test.backtrace2
    BODY

    invocation = ruby 'name_error.rb'
    stderr = strip_color invocation.stderr

    # sanity
      expect(invocation.stdout).to     eq ''
      expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and message
      expect(stderr).to match /NameError.*?undefined local variable or method `backtrace4'/

    # heuristic:
      # It displays a helpful message next to the callsite
      expect(stderr).to match /backtrace4.*?backtrace4 is undefined/

      # It displays the line of the backtrace with the NoMethodError, and some context around it
      expect(stderr).to include 'def self.backtrace2'
      expect(stderr).to include '  backtrace4'
      expect(stderr).to include 'end'
      expect(stderr).to_not include 'error_to_communicate/at_exit'

    # backtrace: It displays each line of the backtrace and includes the code from that line
      expect(stderr).to match /name_error\.rb:7\n.*?backtrace4/
      expect(stderr).to match /name_error\.rb:14\n.*?Test.backtrace2/
  end
end
