require 'spec_helper'

module HeuristicSpecHelpers
  extend self

  def heuristic_class
    raise NotImplementedError, 'You need to define the heuristic class!'
  end

  def heuristic_for(attributes={})
    heuristic_class.new einfo_for FakeException.new attributes
  end

  def is_for!(exception)
    expect(heuristic_class).to be_for einfo_for(exception)
  end

  def is_not_for!(exception)
    expect(heuristic_class).to_not be_for einfo_for(exception)
  end
end

RSpec.configure do |config|
  config.include HeuristicSpecHelpers, heuristic: true
end
