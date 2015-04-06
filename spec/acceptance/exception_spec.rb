require 'acceptance/spec_helper'

RSpec.context 'Exception', acceptance: true do
  it 'Prints heuristics' do
    # Given a file with three lines in the backtrace that explodes on the third
    write_file 'exception.rb', <<-BODY
      require "what_weve_got_here_is_an_error_to_communicate"
      raise Exception, "mah message"
    BODY

    invocation = ruby 'exception.rb'
    stderr = strip_color invocation.stderr

    # sanity
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and prints the message
    expect(stderr).to include 'Exception'
    expect(stderr).to include 'mah message'

    # heuristic displays the line the exception was raised at, and some context
    expect(stderr).to include 'raise Exception, "mah message"'
    expect(stderr).to include 'require "what_weve_got_here_is_an_error_to_communicate"'

    # typical backtrace
    expect(stderr).to include 'exception.rb:2'
  end
end
