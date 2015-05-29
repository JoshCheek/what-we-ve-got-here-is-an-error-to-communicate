require 'error_to_communicate/config'

RSpec.describe 'configuration', config: true do
  # Subclassing to make it a easier to refer to, and to get a new instance
  # (config_class.default will not be affected by changes to Config.default)
  let(:config_class) { Class.new ErrorToCommunicate::Config }

  # named blacklists
  let(:allow_all)  { lambda { |e| false } }
  let(:allow_none) { lambda { |e| true  } }

  # named heuristics
  let :match_all do
    ErrorToCommunicate::Heuristic::Exception
  end

  let :match_no_method_error do
    ErrorToCommunicate::Heuristic::NoMethodError
  end

  # helper methods
  def capture
    yield
    raise 'NO EXCEPTION WAS RAISED!'
  rescue Exception
    return $!
  end

  def yes_accept!(config, ex)
    expect(config.accept? ex).to eq true
  end

  def no_accept!(config, ex)
    expect(config.accept? ex).to eq false
  end

  def config_for(attrs)
    config_class.new attrs
  end

  describe '.default' do
    it 'is a memoized' do
      expect(config_class.default).to equal config_class.default
    end

    it 'is an instance of Config' do
      expect(config_class.default).to be_a_kind_of config_class
    end

    it 'uses the default heuristics and blacklist (behaviour described below)' do
      expect(config_class.default.heuristics).to equal config_class::DEFAULT_HEURISTICS
      expect(config_class.default.blacklist ).to equal config_class::DEFAULT_BLACKLIST
    end
  end

  describe 'accepting an exception' do
    it 'doesn\'t accept non-exception-looking things -- if it can\'t parse it, then we should let the default process take place (eg exception on another system)' do
      config = config_for blacklist:  allow_all, heuristics: [match_all]

      no_accept! config, nil
      no_accept! config, "omg"
      no_accept! config, Struct.new(:message).new('')
      no_accept! config, Struct.new(:backtrace).new([])

      yes_accept! config, Struct.new(:message, :backtrace).new('', [])
      yes_accept! config, capture { raise }
    end

    it 'does not accept anything from its blacklist' do
      config = config_for blacklist: allow_none, heuristics: [match_all]
      no_accept! config, capture { raise }
    end

    it 'accepts anything not blacklisted, that it has a heuristic for' do
      config = config_for blacklist:  allow_all, heuristics: [match_no_method_error]
      yes_accept! config, capture { jjj() }
      no_accept!  config, capture { raise }
    end
  end

  describe 'finding the heuristic for an exception' do
    it 'raises an ArgumentError if given an acception that it won\'t accept' do
      config = config_for blacklist:  allow_none, heuristics: [match_all]
      expect { config.heuristic_for "not an error" }
        .to raise_error ArgumentError, /"not an error"/
    end

    it 'finds the first heuristic that is willing to accept it' do
      config = config_for blacklist:  allow_all,
                          heuristics: [match_no_method_error, match_all]
      exception = capture { sdfsdfsdf() }
      expect(config.heuristic_for exception).to     be_a_kind_of match_no_method_error
      expect(config.heuristic_for exception).to_not be_a_kind_of match_all
    end
  end

  describe 'The default configuration' do
    let(:default_config) { config_class.new }

    describe 'blacklist' do
      it 'doesn\'t accept a SystemExit' do
        system_exit = capture { exit 1 }
        expect(default_config.accept? system_exit).to eq false

        generic_exception = capture { raise }
        expect(default_config.accept? generic_exception).to eq true
      end
    end

    describe 'heuristics (correct selection is tested in spec/acceptance)' do
      it 'has heuristics for WrongNumberOfArguments' do
        expect(default_config.heuristics).to include \
          ErrorToCommunicate::Heuristic::WrongNumberOfArguments
      end

      it 'has heuristics for NoMethodError' do
        expect(default_config.heuristics).to include \
          ErrorToCommunicate::Heuristic::NoMethodError
      end

      it 'has heuristics for Exception' do
        expect(default_config.heuristics).to include \
          ErrorToCommunicate::Heuristic::Exception
      end
    end
  end
end
