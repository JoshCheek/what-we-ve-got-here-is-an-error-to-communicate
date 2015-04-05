require 'acceptance/spec_helper'

RSpec.context 'When there is no error', acceptance: true do
  it 'does nothing' do
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
end
