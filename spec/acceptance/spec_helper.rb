require 'spec_helper'
require 'haiti/command_line_helpers'

module AcceptanceSpecHelpers
  extend self
  include Haiti::CommandLineHelpers

  def root_dir
    File.expand_path '../../..', __FILE__
  end

  def lib_dir
    File.join root_dir, 'lib'
  end

  def proving_grounds_dir
    File.join root_dir, 'proving_grounds'
  end

  def ruby(filename)
    # workaround for JRuby bug (capture3 calls open3 with invalid args, needs to splat an array, but doesn't)
    in_proving_grounds do
      Haiti::CommandLineHelpers::Invocation.new *Open3.capture3(ENV, 'ruby', '-I', lib_dir, filename)
    end
  end

  def strip_color(string)
    string.gsub(/\e\[\d+(;\d+)*?m/, '')
  end
end

# Commandline invocation
Haiti.configure do |config|
  config.proving_grounds_dir = AcceptanceSpecHelpers.proving_grounds_dir
end

RSpec.configure do |config|
  # Helpers for acceptance tests
  config.before(acceptance: true) { make_proving_grounds }
  config.include AcceptanceSpecHelpers, acceptance: true
end
