require 'heuristic/spec_helper'

RSpec.describe 'Heuristic for a NoMethodError', heuristic: true do
  def heuristic_class
    ErrorToCommunicate::Heuristic::NoMethodError
  end

  def extracts_method_name!(expected, message)
    heuristic = heuristic_for message: message
    expect(heuristic.undefined_method_name).to eq expected
  end

  it 'is for NoMethodErrors and NameErrors where it can parse out the missing name' do
    is_for!     NoMethodError.new("undefined method `backtrace4' for Test:Module")
    is_for!     NameError.new("undefined local variable or method `backtrace4' for Test:Module")
    is_not_for! NoMethodError.new("abc")
    is_not_for! NameError.new("abc")
    is_not_for! Exception.new("undefined local variable or method `backtrace4' for Test:Module") # do we actually want to assert this?
  end

  it 'extracts the name of the method that was called' do
    extracts_method_name! '<', "undefined method `<' for nil:NilClass"
    extracts_method_name! "ab `c' d", "undefined method `ab `c' d' for main:Object"
  end

  describe 'on nil' do
    describe 'for an instance variable' do
      it 'suggest a closely spelled variable name if one exists' do
        @abcd = 123
        err = nil
        begin
          @abce.even?
        rescue NoMethodError => no_method_error
          err = no_method_error
        end

        heuristic = heuristic_class.new project: build_default_project,
                                        einfo:   einfo_for(err, binding)
        expect(heuristic.semantic_explanation).to match /@abcd/
        expect(heuristic.semantic_explanation).to match /@abce/
        expect(heuristic.semantic_explanation).to match /spell/
      end

      it 'does not suggest a misspelling when there is no spelled variable' do
        @abcd = 123
        err = nil
        begin
          @ablol.even?
        rescue NoMethodError => no_method_error
          err = no_method_error
        end

        heuristic = heuristic_class.new project: build_default_project,
                                        einfo:   einfo_for(err, binding)
        expect(heuristic.semantic_explanation).to_not match /spell/
        expect(heuristic.semantic_explanation).to_not match /@abcd/
      end

      it 'doesn\'t suggest this when there is no binding provided' do
        @abcd = 123
        err = nil
        begin
          @abce.even?
        rescue NoMethodError => no_method_error
          err = no_method_error
        end

        heuristic = heuristic_class.new project: build_default_project,
                                        einfo:   einfo_for(err, nil)
        expect(heuristic.semantic_explanation).to_not match /spell/
        expect(heuristic.semantic_explanation).to_not match /@abcd/
      end
    end
  end
end
