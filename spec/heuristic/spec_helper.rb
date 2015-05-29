require 'spec_helper'
require 'error_to_communicate/heuristic'

module HeuristicSpecHelpers
  extend self

  def heuristic_class
    raise NotImplementedError, 'You need to define the heuristic class!'
  end

  def heuristic_for(attributes={})
    heuristic_class.new project: build_default_project(attributes),
                        einfo:   einfo_for(FakeException.new attributes)
  end

  def build_default_project(attributes={})
    ErrorToCommunicate::Project.new \
      rubygems_dir: attributes.delete(:rubygems_dir),
      root:         attributes.delete(:root)
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
