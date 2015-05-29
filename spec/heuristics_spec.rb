require 'spec_helper'
require 'error_to_communicate/heuristics'

RSpec.describe 'heuristic management' do
  describe 'constant name to filename' do
    def self.converts!(const_name, filename, description)
      specify "%s -> %s | %s" % [const_name, filename, description] do
        actual_filename = ErrorToCommunicate::Heuristics.filename_for(const_name)
        expect(actual_filename).to eq filename
      end
    end

    converts! :Boring          , 'boring'          , 'Words without internal case changing become downcased'
    converts! :BORING          , 'boring'          , 'Words without internal case changing become downcased'
    converts! :CamelCase       , 'camel_case'      , 'Internal case changes get downcased with a preceding underscore'
    converts! :RSpecError      , 'rspec_error'     , 'consolidate ucase streams'
    converts! :IOError         , 'io_error'        , 'break consolidated streams if they end in Error'
    converts! :AException      , 'a_exception'     , 'break consolidated streams if they end in Exception'
    converts! :SCREAMING_SNAKE , 'screaming_snake' , 'underscores before caps are considered the same thing'
    converts! :abCDef          , 'ab_cdef'         , 'edge case'
    converts! :abCDError       , 'ab_cd_error'     , 'edge case'
    converts! :abCDException   , 'ab_cd_exception' , 'edge case'
  end

  describe 'asking for constants' do
    it 'requires error_to_communicate/heuristics/$FILENAME_FROM_CONSTANT_NAME/autoload to find them' do
      ErrorToCommunicate::Heuristics::Exception # passes if this doesn't raise
    end

    it 'blows up, like normal, if there is no file for that constant' do
      expect { ErrorToCommunicate::Heuristics::ZoMg }.to raise_error NameError, /uninitialized constant ErrorToCommunicate::Heuristics::ZoMg/
    end

    it 'tells you you need to define the constant in that file, if it requires the file, but does not have the constant' do
      expect(ErrorToCommunicate::Heuristics).to receive(:require)
      expect { ErrorToCommunicate::Heuristics::ZoMg }.to raise_error NameError, %r(error_to_communicate/heuristics/zo_mg/autoload)
    end
  end

  describe 'Base' do
    let(:subclass) { Class.new ErrorToCommunicate::Heuristics::Base }
    let(:einfo)    { ErrorToCommunicate::ExceptionInfo.new classname: 'the classname', message: 'the message', backtrace: ['file:12'] }

    it 'expects the subclass to implement .for?' do
      expect { subclass.for? nil }.to raise_error NotImplementedError, /subclass/
    end

    it 'expects the subclass to implement #semantic_message' do
      instance = subclass.new einfo
      expect { instance.semantic_message }.to raise_error NotImplementedError, /subclass/
    end

    it 'records the exception info as einfo' do
      instance = subclass.new einfo
      expect(instance.einfo).to equal einfo
    end

    it 'delegates classname, backtrace, and message to einfo' do
      instance = subclass.new einfo
      expect(instance.classname).to eq 'the classname'
      expect(instance.backtrace).to eq ['file:12']
      expect(instance.message  ).to eq 'the message'
    end
  end
end
