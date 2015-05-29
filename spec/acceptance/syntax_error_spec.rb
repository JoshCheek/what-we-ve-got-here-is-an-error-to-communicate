require 'acceptance/spec_helper'

RSpec.describe 'SyntaxError', acceptance: true do
  it 'Prints heuristics' do
    write_file 'simple_syntax_error.rb', <<-BODY
      100
      "abc" 200
      300
    BODY

    write_file 'requires_simple_sintax_error.rb', <<-BODY
      require "what_weve_got_here_is_an_error_to_communicate"
      require_relative 'simple_syntax_error'
    BODY

    invocation = ruby 'requires_simple_sintax_error.rb'
    stderr = strip_color invocation.stderr

    # sanity
      expect(invocation.stdout).to     eq ''
      expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and message
      expect(stderr).to match /SyntaxError.*?unexpected.*?expected/i

    # heuristic:
      # it displays the error and some context
      expect(stderr).to match /1:.*?100/
      expect(stderr).to match /2:.*"abc" 200.*?unexpected/
      expect(stderr).to match /3:.*?300/
  end
end
