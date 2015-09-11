require 'spec_helper'

RSpec.describe 'Parsing exceptions to ExceptionInfo', einfo: true do
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
      binding = nil
      parsed = ErrorToCommunicate::ExceptionInfo::Location.parse(line, binding)
      assertions.each do |method_name, expected|
        expected = Pathname.new expected if method_name == :path
        actual   = parsed.__send__ method_name
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

    context 'fake backtraces (eg RSpec renders text in the `formatted_backtrace` to get it to print messages there)' do
      it 'has an empty path, linenum of -1, the entire string is the label' do
        binding = nil
        a, b, c = parsed = ErrorToCommunicate::ExceptionInfo.parse_backtrace(
          [ "/Users/josh/.gem/ruby/2.1.1/gems/rspec-core-3.2.3/lib/rspec/core/runner.rb:29:in `block in autorun'",
            "",
            "  Showing full backtrace because every line was filtered out.",
          ],
          binding
        )

        expect(parsed.map(&:path).map(&:to_s)).to eq [
          "/Users/josh/.gem/ruby/2.1.1/gems/rspec-core-3.2.3/lib/rspec/core/runner.rb",
          "",
          "",
        ]

        expect(parsed.map &:linenum).to eq [29, -1, -1]

        expect(parsed.map &:label).to eq [
          "block in autorun",
          "",
          "  Showing full backtrace because every line was filtered out.",
        ]

        expect(parsed.map &:pred).to eq [b, c, nil]
        expect(parsed.map &:succ).to eq [nil, a, b]
      end
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

  describe 'ExceptionInfo::Location' do
    def location_for(attrs)
      attrs[:binding] ||= nil
      ErrorToCommunicate::ExceptionInfo::Location.new attrs
    end

    it 'hashes take into account its path, linenum, and label' do
      loc_base         = location_for(path: 'p', linenum: 123, label: 'l')
      loc_eq1          = location_for(path: 'p', linenum: 123, label: 'l')
      loc_eq2          = location_for(path: 'p', linenum: 123, label: 'l', succ: loc_base, pred: loc_base)
      loc_diff_path    = location_for(path: 'P', linenum: 123, label: 'l')
      loc_diff_linenum = location_for(path: 'p', linenum: 999, label: 'l')
      loc_diff_label   = location_for(path: 'p', linenum: 123, label: 'L')

      expect(loc_base.hash).to eq loc_eq1.hash # same values gets same hash
      expect(loc_base.hash).to eq loc_eq2.hash # succ/pred are excluded from hash
      expect(loc_base.hash).to_not eq loc_diff_path.hash
      expect(loc_base.hash).to_not eq loc_diff_linenum.hash
      expect(loc_base.hash).to_not eq loc_diff_label.hash

      # use this, just to show it works
      h = {loc_base => :found}
      expect( h[loc_eq1          ] ).to eq :found
      expect( h[loc_eq2          ] ).to eq :found
      expect( h[loc_diff_path    ] ).to eq nil
      expect( h[loc_diff_linenum ] ).to eq nil
      expect( h[loc_diff_label   ] ).to eq nil
    end


    # Can't directly check associations for equality or we'll end up in an infinite loop
    # This was maybe a waste of time, to specify it this precisely, all I want to be able to do is compare two paths -.^
    it 'is == and eql? to another location, if their paths, linenums, and labels are ==' do
      # the rest are compared against this
      loc1            = location_for path: 'p1', linenum: 1, label: 'l1'

      # equivalent
      loc1_same       = location_for path: 'p1', linenum: 1, label: 'l1'
      expect(loc1).to eq  loc1_same
      expect(loc1).to eql loc1_same

      # different path
      loc1_diff_path  = location_for path: 'p2', linenum: 1, label: 'l1'
      expect(loc1).to_not eq  loc1_diff_path
      expect(loc1).to_not eql loc1_diff_path

      # different line
      loc1_diff_line  = location_for path: 'p1', linenum: 2, label: 'l1'
      expect(loc1).to_not eq  loc1_diff_line
      expect(loc1).to_not eql loc1_diff_line

      # different label
      loc1_diff_label = location_for path: 'p1', linenum: 1, label: 'l2'
      expect(loc1).to_not eq  loc1_diff_label
      expect(loc1).to_not eql loc1_diff_label

      # are == when different before
      loc2_before     = location_for path: 'p2', linenum: 2, label: 'l2'
      loc2            = location_for path: 'p1', linenum: 1, label: 'l1'
      loc2.succ, loc2_before.pred = loc2_before, loc2
      expect(loc1).to eq  loc2
      expect(loc1).to eql loc2

      # are == when different after
      loc3            = location_for path: 'p1', linenum:  1, label: 'l1'
      loc3_after      = location_for path: 'p2', linenum:  2, label: 'l2'
      loc3.succ, loc3_after.pred = loc3_after, loc3
      expect(loc1).to eq  loc3
      expect(loc1).to eql loc3
    end

    it 'inspects to something that isn\'t obnoxious to look at' do
      linked_loc = location_for path: 'somepath', linenum:  123, label: 'somelabel'
      linked_loc.succ, linked_loc.pred = linked_loc, linked_loc
      expect(linked_loc.inspect).to eq '#<ExInfo::Loc somepath:123:in `somelabel\' pred:true succ:true>'

      unlinked_loc = location_for path: 'anotherpath', linenum: 12, label: 'anotherlabel'
      expect(unlinked_loc.inspect).to eq '#<ExInfo::Loc anotherpath:12:in `anotherlabel\' pred:false succ:false>'
    end
  end

end
