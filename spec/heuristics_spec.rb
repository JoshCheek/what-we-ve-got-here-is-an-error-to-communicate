require 'spec_helper'
require 'error_to_communicate/heuristic'

RSpec.describe 'Heuristic' do
  let(:subclass) { Class.new ErrorToCommunicate::Heuristic }
  let(:einfo)    { ErrorToCommunicate::ExceptionInfo.new classname: 'the classname', message: 'the message', backtrace: ['file:12'] }

  it 'expects the subclass to implement .for?' do
    expect { subclass.for? nil }.to raise_error NotImplementedError, /subclass/
  end

  it 'records the exception info as einfo' do
    instance = subclass.new einfo
    expect(instance.einfo).to equal einfo
  end

  it 'delegates classname, and backtrace to einfo' do
    instance = subclass.new einfo
    expect(instance.classname).to eq 'the classname'
    expect(instance.backtrace).to eq ['file:12']
  end

  it 'defaults the explanation to einfo\'s message' do
    instance = subclass.new einfo
    expect(instance.explanation).to eq 'the message'
  end

  it 'defines the semantic explanation to the message' do
    instance = subclass.new einfo
    expect(instance.semantic_explanation).to eq [:message, 'the message']
  end
end
