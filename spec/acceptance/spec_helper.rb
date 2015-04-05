require 'haiti/command_line_helpers'

module AcceptanceSpecHelpers
  extend self

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
    execute "ruby -I #{lib_dir} #{filename}", '', ENV
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
  # Stop testing after first failure
  config.fail_fast = true

  # Don't define should/describe on Object
  config.disable_monkey_patching!

  # Helpers for acceptance tests
  config.before(acceptance: true) { make_proving_grounds }
  config.include Haiti::CommandLineHelpers, acceptance: true
  config.include AcceptanceSpecHelpers,     acceptance: true
end
