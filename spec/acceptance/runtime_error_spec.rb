require 'acceptance/spec_helper'

RSpec.describe 'RuntimeError', acceptance: true do
  it 'Prints heuristics' do
    write_file 'runtime_error.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      raise 'omg'
      1
    BODY

    invocation = ruby 'runtime_error.rb'
    stderr = strip_color invocation.stderr

    # sanity
      expect(invocation.stdout).to     eq ''
      expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and message
      expect(stderr).to match /RuntimeError.*?omg/

    # heuristic:
      # it displays the error and some context
      expect(stderr).to match /1:.*?require 'error_to_communicate\/at_exit'/
      expect(stderr).to match /2:.*?raise 'omg'/
      expect(stderr).to match /3:.*?1/
  end
end
