require 'spec_helper'

RSpec.describe 'parsing', parse: true do
  it 'records the class name, message, and backtrace' do
    exception = FakeException.new message:   'Some message',
                                  backtrace: ["/Users/someone/a/b/c.rb:123:in `some_method_name'"]
    einfo = einfo_for exception
    expect(einfo.classname  ).to eq 'FakeException'
    expect(einfo.message    ).to eq 'Some message'
    expect(einfo.backtrace.map &:linenum).to eq [123]
  end

  describe 'recording the actual exception' do
    let(:exception) { FakeException.new }
    let(:einfo)     { einfo_for exception }

    it 'records the exception for informational purposes' do
      trap_warnings do
        expect(einfo.exception).to equal exception
      end
    end

    it 'warns the first time you try to use it (ie available for debugging, but not for development)' do
      warnings = trap_warnings { einfo.exception }
      expect(warnings).to match /debugging/

      warnings = trap_warnings { einfo.exception }
      expect(warnings).to be_empty
    end
  end

  describe 'backtrace' do
    let :exception do
      FakeException.new backtrace: [
        "file.rb:111:in `method1'",
        "file.rb:222:in `method2'",
        "file.rb:333:in `method3'",
      ]
    end

    def backtrace_for(exception)
      einfo_for(exception).backtrace
    end

    it 'records the linenum, and label of each backtrace location' do
      locations = backtrace_for exception
      expect(locations.map &:linenum).to eq [111, 222, 333]
      expect(locations.map &:label).to eq %w[method1 method2 method3]
    end

    specify 'the successor is the parsed location that was called, or nil for the first' do
      l1, l2, l3 = locations = backtrace_for(exception)
      expect(locations.map &:succ).to eq [nil, l1, l2]
    end

    specify 'the predecessor is the parsed location from the caller, or nil for the last' do
      l1, l2, l3 = locations = backtrace_for(exception)
      expect(locations.map &:pred).to eq [l2, l3, nil]
    end

    # it 'records the absolute filepath if it can find the file'
    # it 'records the relative filepath if it can find the file'
    # it 'records the relative filepath if it cannot fild the file'

    def assert_parses_line(line, assertions)
      parsed = ErrorToCommunicate::ExceptionInfo::Location.parse(line)
      assertions.each do |method_name, expected|
        actual = parsed.__send__ method_name
        expect(actual).to eq expected
      end
    end

    it 'records the path whether its absolute or relative' do
      assert_parses_line "file.rb:111:in `method1'",  path: "file.rb"
      assert_parses_line "/file.rb:111:in `method1'", path: "/file.rb"
    end

    it 'does not get confused by numbers in directories, filenames, or method names' do
      line = "/a1/b2/c3123/file123.rb:111:in `method1'"
      assert_parses_line line, path:    "/a1/b2/c3123/file123.rb"
      assert_parses_line line, linenum: 111
      assert_parses_line line, label:   "method1"
    end

    context 'random ass colons in the middle of like files and directories and shit' do
      # $ mkdir 'a:b'
      # $ echo 'begin; define_method("a:b") { |arg| }; send "a:b"; rescue Exception; p $!.backtrace; end' > 'a:b/c:d.rb'

      # $ chruby-exec 2.2 -- ruby -v
      # > ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin13]
      #
      # $ chruby-exec 2.2 -- ruby 'a:b/c:d.rb'
      # > ["a:b/c:d.rb:1:in `block in <main>'", "a:b/c:d.rb:1:in `<main>'"]
      it 'does not get confused with MRI style results' do
        line = "a:b/c:d.rb:1:in `block in <main>'"
        assert_parses_line line, path:    "a:b/c:d.rb"
        assert_parses_line line, linenum: 1
        assert_parses_line line, label:   "block in <main>"
      end

      # $ chruby-exec rbx -- ruby -v
      # > rubinius 2.5.0 (2.1.0 50777f41 2015-01-17 3.5.0 JI) [x86_64-darwin14.1.0]
      #
      # $ chruby-exec rbx -- ruby 'a:b/c:d.rb'
      # > ["a:b/c:d.rb:1:in `__script__'",
      #    "kernel/delta/code_loader.rb:66:in `load_script'",
      #    "kernel/delta/code_loader.rb:152:in `load_script'",
      #    "kernel/loader.rb:645:in `script'",
      #    "kernel/loader.rb:799:in `main'"]
      it 'does not get confused with RBX style results' do
        line = "a:b/c:d.rb:1:in `__script__'"
        assert_parses_line line, path:    "a:b/c:d.rb"
        assert_parses_line line, linenum: 1
        assert_parses_line line, label:   "__script__"
      end

      # $ chruby-exec jruby -- ruby -v
      # > jruby 1.7.16 (1.9.3p392) 2014-09-25 575b395 on Java HotSpot(TM) 64-Bit Server VM 1.7.0_51-b13 +jit [darwin-x86_64]
      #
      # $ chruby-exec jruby -- ruby 'a:b/c:d.rb'
      # > ["a:b/c:d.rb:1:in `(root)'"]
      it 'does not get confused by Jruby style results' do
        line = "a:b/c:d.rb:1:in `(root)'"
        assert_parses_line line, path:    "a:b/c:d.rb"
        assert_parses_line line, linenum: 1
        assert_parses_line line, label:   "(root)"
      end
    end
  end

end
