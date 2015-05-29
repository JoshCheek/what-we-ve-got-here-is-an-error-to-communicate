require 'acceptance/spec_helper'

RSpec.context 'LoadError', acceptance: true do
  it 'Prints heuristics' do
    write_file 'load_error.rb', <<-BODY
      require "what_weve_got_here_is_an_error_to_communicate"
      require "not/a/real/dir"
    BODY

    invocation = ruby 'load_error.rb'
    stderr     = strip_color invocation.stderr

    # sanity
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and prints the message
    expect(stderr).to match %r(LoadError.*?load.*?not/a/real/dir)

    # heuristic displays the line the exception was raised at, and some context
    expect(stderr).to match %r(2:.*?require "not/a/real/dir".*?Couldn't find file)
  end
end
