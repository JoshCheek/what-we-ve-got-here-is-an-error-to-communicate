require 'error_to_communicate/parse'

RSpec.describe 'registered parsers' do
  include WhatWeveGotHereIsAnErrorToCommunicate

  def capture
    yield
    raise 'NO EXCEPTION WAS RAISED!'
  rescue Exception
    return $!
  end

  describe 'selected parsers' do
    def parser_for(exception)
      WhatWeveGotHereIsAnErrorToCommunicate::Parse::DEFAULT_REGISTRY
        .parser_for(exception)
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

    it 'parses ArgumentErrors' do
      err = capture { lambda { }.call :arg }
      expect(parser_for err).to eq WhatWeveGotHereIsAnErrorToCommunicate::Parse::ArgumentError
    end

    it 'parses NoMethodErrors' do
      err = capture { sdfsdfsdf() }
      expect(parser_for err).to eq WhatWeveGotHereIsAnErrorToCommunicate::Parse::NoMethodError
    end

    it 'parses Exception'
  end

  describe 'parse' do
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
