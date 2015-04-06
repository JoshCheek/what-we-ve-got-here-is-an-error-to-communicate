require 'acceptance/spec_helper'

RSpec.context 'non errors are not captured/reported', acceptance: true do
  example 'no error is raised' do
    write_file 'no_error.rb', <<-BODY
      require 'what_weve_got_here_is_an_error_to_communicate'
      print "hello, world"
    BODY

    invocation = ruby 'no_error.rb'

    # No exception
    expect(invocation.stderr).to     eq ''
    expect(invocation.stdout).to     eq 'hello, world'
    expect(invocation.exitstatus).to eq 0
  end


  example 'successful exit' do
    write_file 'exit_0.rb', <<-BODY
      require 'what_weve_got_here_is_an_error_to_communicate'
      exit 0
    BODY
    invocation = ruby 'exit_0.rb'

    # No exception
    expect(invocation.stderr).to     eq ''
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 0
  end

  example 'unsuccessful exit' do
    write_file 'exit_2.rb', <<-BODY
      require 'what_weve_got_here_is_an_error_to_communicate'
      exit 2
    BODY
    invocation = ruby 'exit_2.rb'

    # No exception
    expect(invocation.stderr).to     eq ''
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 2
  end
end
