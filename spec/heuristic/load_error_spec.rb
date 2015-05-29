require 'heuristic/spec_helper'

RSpec.describe 'Heuristic for a LoadError', heuristic: true do
  def heuristic_class
    ErrorToCommunicate::Heuristic::LoadError
  end

  it 'is for LoadErrors with a message that includes " -- " to separate the message from the path' do
    is_for! LoadError.new 'cannot load such file -- a/b/c'
    is_for! LoadError.new "no such file to load -- /a/b/c\ndef\tghi\ejkl"
    is_for! LoadError.new(' -- ')
    is_not_for! LoadError.new('-- ')
    is_not_for! LoadError.new(' --')
    is_not_for! LoadError.new('whatever')
    is_not_for! LoadError.new('what-ever')
  end

  describe 'methods that can lead to this error' do
    it('works for require')          { is_for! capture { require 'a/b/c' } }
    it('works for require_relative') { is_for! capture { require_relative 'a/b/c' } }
    it('works for load')             { is_for! capture { load 'a/b/c' } }
  end

  describe 'identifying the missing path' do
    def heuristic_for_path(path)
      heuristic_for message: "cannot load such file -- #{path}"
    end

    def identifies!(path, expected=path)
      heuristic_for_path(path).tap { |h| expect(h.path).to eq Pathname.new(expected) }
    end

    def absolute!(path)
      heuristic = heuristic_for_path(path)
      expect(heuristic).to     be_absolute
      expect(heuristic).to_not be_relative
    end

    def relative!(path)
      heuristic = heuristic_for_path(path)
      expect(heuristic).to_not be_absolute
      expect(heuristic).to     be_relative
    end

    it('identifies paths without directories')        { identifies! 'thepath' }
    it('identifies paths with underscores')           { identifies! 'the_path' }
    it('identifies paths within directories')         { identifies! 'this/is/a/path' }
    it('identifies empty strings')                    { identifies! "" }
    it('identifies empty space filenames')            { identifies! " " }
    it('identifies filenames that begin with spaces') { identifies! " abc" }
    it('identifies filenames that end with spaces')   { identifies! "abc " }
    it('identifies paths with whitespace')            { identifies! "a b" }
    it('identifies paths with dashes')                { identifies! 'a-b - c  -  d' }
    it('identifies paths with double dashes')         { identifies! 'a--b -- c  --  d' }
    it('identifies paths with escaped characters')    { identifies! 'a\nb\tc\ed' }
    # Not sure if it should do this, or provide both the relative and absolute path
    # it 'expands paths from the home-dir to be absolute' do
    #   identifies! '/a/b/c', '/a/b/c'
    #   identifies! 'a/b/c',  'a/b/c'
    #   identifies! '~/a/b/c', "#{ENV['HOME']}/a/b/c"
    #   identifies! '~a/b/c',  '~a/b/c'
    # end
  end

  describe 'identification of the relevant locations from the backtrace' do
    it 'identifies the first line that is outside of rubygems' do
      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/a/c:2:in `c'", "/d:3:in `d'", "/e:4:in `e'"
      ], rubygems_dir: '/a'
      expect(heuristic.first_nongem_line.path.to_s).to eq '/d'

      heuristic = heuristic_for backtrace: [
        "/b:2:in `b'", "/c:3:in `c'"
      ], rubygems_dir: '/a'
      expect(heuristic.first_nongem_line.path.to_s).to eq '/b'

      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c:2:in `c'", "/d:3:in `d'"
      ], rubygems_dir: '/a/b'
      expect(heuristic.first_nongem_line.path.to_s).to eq '/c'

      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c:2:in `c'", "/d:3:in `d'"
      ], rubygems_dir: '/'
      expect(heuristic.first_nongem_line).to eq nil
    end

    it 'identifies the line within the project root' do
      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c:2:in `c'", "/d:3:in `d'"
      ], root: '/a'
      expect(heuristic.first_line_within_lib.path.to_s).to eq '/a/b'

      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c/d:2:in `c'", "/e:3:in `e'"
      ], root: '/c'
      expect(heuristic.first_line_within_lib.path.to_s).to eq '/c/d'

      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c/d:2:in `c'", "/e:3:in `e'"
      ], root: '/x'
      expect(heuristic.first_line_within_lib).to eq nil
    end

    specify 'when they are different, it displays them both' do
      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c/d:2:in `c'", "/e:3:in `e'"
      ], root: '/c'
      expect(heuristic.relevant_locations.map(&:path).map(&:to_s)).to eq ['/a/b', '/c/d']
    end

    specify 'when they are the same, it only displays them once' do
      heuristic = heuristic_for backtrace: [
        "/a/b:1:in `a'", "/c/d:2:in `c'", "/e:3:in `e'"
      ], root: '/a'
      expect(heuristic.relevant_locations.map(&:path).map(&:to_s)).to eq ['/a/b']
    end

    specify 'when either is missing, it displays the other' do
      heuristic = heuristic_for backtrace: ["/a/b:1:in `a'"], root: '/b'
      expect(heuristic.relevant_locations.map(&:path).map(&:to_s)).to eq ['/a/b']
    end

    specify 'when both are missing, it displays a message stating this' do
      heuristic = heuristic_for backtrace: ["/a/b:1:in `a'"],
                                root: '/b',
                                rubygems_dir: '/a'
      expect(heuristic.relevant_locations).to eq []
      name, (context, message) = heuristic.semantic_info
      expect(name).to eq :heuristic
      expect(context).to eq :context
      expect(message).to be_a_kind_of String
    end
  end

  describe 'displaying relevant code' do
    let :semantic_code do
      _heuristic, ((_code, code_attrs), *) =
        heuristic_for(root:      '/a',
                      backtrace: ["/a/b:1:in `a'"],
                      message:   'cannot load such file -- zomg'
                     ).semantic_info
      expect(code_attrs[:location].path.to_s).to eq '/a/b'
      code_attrs
    end

    # TODO: Should 5 be configurable?
    it 'includes 5 lines of context before/after' do
      expect(semantic_code[:context]).to eq (-5..5)
    end

    it 'emphasizes the code' do
      expect(semantic_code[:emphasis]).to eq :code
    end

    context 'when the line includes the path' do
      it 'has the message "Couldn\'t find file"' do
        skip 'Waiting b/c it\'s inconvenient right now to get the code in the heuristic'
      end
    end

    context 'when the line does not include the path' do
      it 'has the message "Couldn\'t find \"<FILE>\""' do
        expect(semantic_code[:message]).to eq 'Couldn\'t find "zomg"'
      end
    end
  end

  # Maybe eventuallly:
  #
  # it identifies that they are trying to require a file from a gem they don't have
  # When the require statement is relative (require "./something")
  #   it identifies that they could have required it if run from a different directory
  #   it gives them the `require_relative` path
  #   it tells them how to set up the $LOAD_PATH to avoid the need for such things
  #   it tells them where they would need to make the file, and warns of the danger of this approach
  # When using require_relative
  #   it identifies misspellings in the require statement
  #   it identifies candidate files that could be required if the path were different
  #   it tells them where they would need to make the file
  # When the require statement is not relative (require "something")
  #   it identifies misspellings for files they could have required
  #   it identifies that they meant to require something from a gem
  #     if not using Bundler, tells them to `bundle exec` it
  #     if using Bundler
  #       if the gem is not part of the Gemfile, tells them how to add it
  #       if the gem is part of the Gemfile, suggests they check versions
  #   it tells them places they could make the file that are within their lib
  #
  # It could possibly look at constant names that they use after the require statement,
  #   if any of them look sufficiently similar to the require statement,
  #   assuming that the require statement was intended to make that constant available
  #   if it can then identify where the constant is defined,
  #   then it could tell them which file to require to get it.
end
