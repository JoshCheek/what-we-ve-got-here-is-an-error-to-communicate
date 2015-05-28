require 'acceptance/spec_helper'

RSpec.context 'Short and long require statements', acceptance: true do
  it 'can require error_to_communicate' do
    write_file 'require_shorthand.rb', <<-BODY
      require 'error_to_communicate/at_exit'
      ErrorToCommunicate
      ErrorToCommunicate
    BODY

    invocation = ruby 'load_shorthand.rb'
    expect(invocation.stdout).to     eq ''
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 1
  end

  it 'can require what_weve_got_here_is_an_error_to_communicate' do
    write_file 'require_longhand.rb', <<-BODY
      require 'what_weve_got_here_is_an_error_to_communicate'
      ErrorToCommunicate
      ErrorToCommunicate
    BODY

    invocation = ruby 'load_longhand.rb'
    expect(invocation.stdout).to     eq ''
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 1
  end
end
