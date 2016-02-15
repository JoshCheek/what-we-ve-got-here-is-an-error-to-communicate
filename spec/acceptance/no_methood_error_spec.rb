require 'acceptance/spec_helper'

RSpec.describe 'NoMethodError', acceptance: true do
  it 'Prints heuristics' do
    # a file that throws an error with two lines in the backtrace
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
      # It displays a helpful message next to the callsite
      expect(stderr).to match /Test\.backtrace4.*?backtrace4 is undefined/

      # It displays the line of the backtrace with the NoMethodError, and some context around it
      expect(stderr).to include 'def self.backtrace2'
      expect(stderr).to include '  Test.backtrace4'
      expect(stderr).to include 'end'
      expect(stderr).to_not include 'error_to_communicate/at_exit'

    # backtrace: It displays each line of the backtrace and includes the code from that line
      expect(stderr).to match /no_method_error\.rb:7\n.*?backtrace4/
      expect(stderr).to match /no_method_error\.rb:14\n.*?Test.backtrace2/
  end



  it 'doesn\'t freak out on methods with punctuation names' do
    # https://github.com/JoshCheek/mrspec/issues/11
    write_file 'punctuation_no_method_error.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      class Bowling
        def self.score(rolls)
          new(rolls).score
        end

        def initialize(rolls)
          @rolls = rolls
        end

        def score(total=0)
          current = rolls.shift
          if strike?
            current + rolls[1] + rolls[2] + total
          else
            current + total
          end
        end

        private

        attr_reader :rolls

        def strike?
          self[0] == 10
        end
      end

      Bowling.score([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    BODY

    invocation = ruby 'punctuation_no_method_error.rb'
    stderr = strip_color invocation.stderr

    # sanity
      expect(invocation.stdout).to     eq ''
      expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and message
      expect(stderr).to include 'NoMethodError'
      expect(stderr).to include "undefined method `[]'"

    # heuristic:
      expect(stderr).to match /self\[0\] == 10  \[\] is undefined/

    # backtrace: It displays each line of the backtrace and includes the code from that line
      expect(stderr).to match /punctuation_no_method_error\.rb:25/
      expect(stderr).to match /punctuation_no_method_error\.rb:13/
      expect(stderr).to match /punctuation_no_method_error\.rb:4/
      expect(stderr).to match /punctuation_no_method_error\.rb:29/
  end
end
