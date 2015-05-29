require 'spec_helper'
require 'error_to_communicate/heuristic'
require 'heuristic/spec_helper'

RSpec.describe 'Heuristic', heuristic: true do
  let(:einfo)    { ErrorToCommunicate::ExceptionInfo.new classname: 'the classname', message: 'the message', backtrace: [
                     ErrorToCommunicate::ExceptionInfo::Location.new(path: 'file', linenum: 12, label: 'a')
                   ]
                 }
  let(:subclass) { Class.new ErrorToCommunicate::Heuristic }
  let(:instance) { subclass.new einfo: einfo, project: build_default_project }

  it 'expects the subclass to implement .for?' do
    expect { subclass.for? nil }.to raise_error NotImplementedError, /subclass/
  end

  it 'records the exception info as einfo' do
    expect(instance.einfo).to equal einfo
  end

  it 'delegates classname, and backtrace to einfo' do
    expect(instance.classname).to eq 'the classname'
    expect(instance.backtrace.map { |loc| [loc.linenum] }).to eq [[12]]
  end

  it 'defaults the explanation to einfo\'s message' do
    expect(instance.explanation).to eq 'the message'
  end

  describe 'semantic methods' do
    specify 'semantic_explanation defaults to the explanation' do
      def instance.explanation; "!#{einfo.message}!"; end
      expect(instance.semantic_explanation).to eq "!the message!"
    end

    specify 'semantic_summary includes the classname and semantic_explanation in columns' do
      def instance.semantic_explanation; 'sem-expl'; end
      expect(instance.semantic_summary).to eq \
        [:summary, [
          [:columns,
            [:classname,   'the classname'],
            [:explanation, 'sem-expl']]]]
    end

    specify 'semantic_info is null by default' do
      expect(instance.semantic_info).to eq [:null]
    end

    describe 'semantic_backtrace' do
      it 'is marked as a backtrace' do
        expect(instance.semantic_backtrace.first).to eq :backtrace
      end

      it 'includes code for each line of the backtrace, without context, highlighting the label of the predecessor, and emphasizing the path over the code' do
        err  = RuntimeError.new('the message')
        err.set_backtrace ["file1:12:in `a'", "file2:100:in `b'", "file3:94:in `c'"]
        einfo        = einfo_for err
        instance     = subclass.new einfo: einfo, project: build_default_project
        code_samples = instance.semantic_backtrace.last
        metas        = code_samples.map do |name, metadata, *rest|
          expect(name).to eq :code
          expect(rest).to be_empty
          metadata
        end

        locations       = metas.map { |m| m[:location] }
        highlights      = metas.map { |m| m[:highlight] }
        paths_and_lines = locations.flat_map { |l| [l.path.to_s, l.linenum] }
        expect(paths_and_lines).to eq ['file1', 12, 'file2', 100, 'file3', 94]
        expect(highlights).to eq ['b', 'c', nil]
        expect(metas).to be_all { |m| m[:context] == (0..0) }
        expect(metas).to be_all { |m| m[:emphasis] == :path }
      end
    end
  end
end
