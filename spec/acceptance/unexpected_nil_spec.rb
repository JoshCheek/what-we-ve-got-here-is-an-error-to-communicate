require 'acceptance/spec_helper'

RSpec.context 'Exception', acceptance: true do
  it 'Prints heuristics' do
    write_file 'misspelled_ivar.rb', <<-BODY
      require "what_weve_got_here_is_an_error_to_communicate"
      User  = Struct.new :name

      class Email
        def initialize(user)
          @user = user
        end

        def body
          "Dear, \#{@uesr.name}, <3 <3 <3"
        end
      end

      Email.new(User.new 'Jorge').body
    BODY

    invocation = ruby 'misspelled_ivar.rb'
    stderr     = strip_color invocation.stderr

    # sanity
    expect(invocation.stdout).to     eq ''
    expect(invocation.exitstatus).to eq 1

    # error: It prints the exception class and prints the message
    expect(stderr).to match /NoMethodError/
    expect(stderr).to match /You called the method `name' on `@uesr', which is nil/

    # Suggests a fix
    expect(stderr).to match /possible misspelling of `@user'/i

    # Shows where the method was called
    expect(stderr).to include '"Dear, #{@uesr.name}, <3 <3 <3"'

    # MAYBE: shows where the correctly spelled variable was set

    # typical backtrace
    expect(stderr).to include 'misspelled_ivar.rb:10'
  end
end
