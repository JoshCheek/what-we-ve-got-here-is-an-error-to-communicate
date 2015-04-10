require 'spec_helper'

module HeuristicSpecHelpers
  extend self

  def heuristic_class
    raise NotImplementedError, 'You need to define the heuristic class!'
  end

  # TODO: this could also be called info_for,
  # and is probably generally useful enough to move to toplevel spec_helper
  def parse_exception(exception)
    WhatWeveGotHereIsAnErrorToCommunicate::ExceptionInfo.parse exception
  end

  def heuristic_for(attributes={})
    heuristic_class.new parse_exception FakeException.new attributes
  end

  def is_for!(exception)
    expect(heuristic_class).to be_for parse_exception(exception)
  end

  def is_not_for!(exception)
    expect(heuristic_class).to_not be_for parse_exception(exception)
  end
end

RSpec.configure do |config|
  config.include HeuristicSpecHelpers, heuristic: true
end
