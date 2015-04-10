require 'error_to_communicate/config'

RSpec.describe 'configuration', config: true do
  # TODO: make test heuristics / blacklists RejectAll/AcceptAll

  def capture
    yield
    raise 'NO EXCEPTION WAS RAISED!'
  rescue Exception
    return $!
  end

  def config_for(attrs)
    WhatWeveGotHereIsAnErrorToCommunicate::Config.new(attrs)
  end

  describe '.default' do
    it 'is a memoized' do
      default1 = WhatWeveGotHereIsAnErrorToCommunicate::Config.default
      default2 = WhatWeveGotHereIsAnErrorToCommunicate::Config.default
      expect(default1).to equal default2
    end

    it 'is an instance of a default parser' do
      default = WhatWeveGotHereIsAnErrorToCommunicate::Config.default
      expect(default).to be_a_kind_of WhatWeveGotHereIsAnErrorToCommunicate::Config
      expect(default.heuristics).to equal WhatWeveGotHereIsAnErrorToCommunicate::Config::DEFAULT_HEURISTICS
      expect(default.blacklist).to equal WhatWeveGotHereIsAnErrorToCommunicate::Config::DEFAULT_BLACKLIST
    end
  end

  describe 'accepting an exception' do
    it 'doesn\'t accept non-exception-looking things' do
      config = config_for blacklist:  lambda { |e| false }, #  allow everything
                          heuristics: [WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception]
      expect(config.accept? nil).to eq false
      expect(config.accept? "omg").to eq false
      expect(config.accept? Struct.new(:message).new('')).to eq false
      expect(config.accept? Struct.new(:backtrace).new([])).to eq false
      expect(config.accept? Struct.new(:message, :backtrace).new('', [])).to eq true
      expect(config.accept? capture { raise }).to eq true
    end

    it 'does not accept anything from its blacklist' do
      config = config_for blacklist:  lambda { |e| true }, # deny everything
                          heuristics: [WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception] # accept everything
      expect(config.accept? capture { raise }).to eq false
    end

    it 'accepts anything not blacklisted, that it has a heuristic for' do
      config = config_for blacklist:  lambda { |e| false }, #  allow everything
                          heuristics: [WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::NoMethodError] # accept only NoMethodErrors
      expect(config.accept? capture { jjj() }).to eq true
      expect(config.accept? capture { raise }).to eq false
    end
  end

  describe 'finding the heuristic for an exception' do
    def parse(exception)
      WhatWeveGotHereIsAnErrorToCommunicate::Config
        .new.parse(exception)
    end

    it 'raises an ArgumentError if given an acception that it won\'t accept' do
      config = config_for blacklist:  lambda { |e| true }, # deny everything
                          heuristics: [WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception] # accept everything
      expect { config.heuristic_for "not an error" }.to raise_error ArgumentError, /"not an error"/
    end

    it 'finds the first heuristic that is willing to accept it' do
      config = config_for blacklist:  lambda { |e| false }, # accept everything
                          heuristics: [
                            WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::NoMethodError, # accept NoMethodError
                            WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception      # accept everything
                          ]
      exception = capture { sdfsdfsdf() }
      expect(config.heuristic_for exception).to     be_a_kind_of WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::NoMethodError
      expect(config.heuristic_for exception).to_not be_a_kind_of WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception # in case, at some point, they wind up using inheritance or something
    end
  end

  describe 'The default configuration' do
    let(:default_config) { WhatWeveGotHereIsAnErrorToCommunicate::Config.new_default }

    describe 'blacklist' do
      it 'doesn\'t accept a SystemExit' do
        system_exit = capture { exit 1 }
        expect(default_config.accept? system_exit).to eq false

        generic_exception = capture { raise }
        expect(default_config.accept? generic_exception).to eq true
      end
    end

    describe 'heuristics (these are unit-tested in spec/heuristics, and correct selection is tested in spec/acceptance)' do
      it 'has heuristics for WrongNumberOfArguments' do
        expect(default_config.heuristics).to include \
          WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::WrongNumberOfArguments
      end

      it 'has heuristics for NoMethodError' do
        expect(default_config.heuristics).to include \
          WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::NoMethodError
      end

      it 'has heuristics for Exception' do
        expect(default_config.heuristics).to include \
          WhatWeveGotHereIsAnErrorToCommunicate::Heuristics::Exception
      end
    end
  end
end
