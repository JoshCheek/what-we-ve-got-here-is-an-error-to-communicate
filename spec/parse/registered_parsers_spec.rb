require 'error_to_communicate/config'

RSpec.describe 'registered parsers' do
  p = WhatWeveGotHereIsAnErrorToCommunicate::Parse

  def capture
    yield
    raise 'NO EXCEPTION WAS RAISED!'
  rescue Exception
    return $!
  end

  describe 'selected parsers' do
    def parser_for(exception)
      WhatWeveGotHereIsAnErrorToCommunicate::Config
        .new.registry.parser_for(exception)
    end

    it 'doesn\'t parse nil' do
      expect(parser_for nil).to eq nil
    end

    it 'doesn\'t parse a SystemExit' do
      err = capture { exit }
      expect(parser_for err).to eq nil

      err = capture { exit 1 }
      expect(parser_for err).to eq nil
    end

    it 'parses wrong number of arguments' do
      err = capture { lambda { }.call :arg }
      expect(parser_for err).to eq p::ArgumentError
    end

    it 'parses NoMethodErrors' do
      err = capture { sdfsdfsdf() }
      expect(parser_for err).to eq p::NoMethodError
    end

    it 'parses Exception' do
      err = capture { raise Exception, "wat" }
      expect(parser_for err).to eq p::Exception
    end
  end

  describe 'config.parse' do
    def parse(exception)
      WhatWeveGotHereIsAnErrorToCommunicate::Config
        .new.parse(exception)
    end

    it 'parses the exception if anything is willing to do it' do
      exception      = capture { sdfsdfsdf() }
      exception_info = parse exception
      expect(exception_info.exception).to equal exception
    end

    it 'raises an ArgumentError if there are no parsers for this exception' do
      expect { parse "not an error" }.to raise_error ArgumentError, /"not an error"/
    end
  end
end
