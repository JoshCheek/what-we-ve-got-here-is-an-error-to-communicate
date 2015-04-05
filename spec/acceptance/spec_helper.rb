require 'haiti/command_line_helpers'

root_dir            = File.expand_path '../../..', __FILE__
lib_dir             = File.join(root_dir, 'lib')
proving_grounds_dir = File.join(root_dir, 'proving_grounds')

Haiti.configure do |config|
  config.proving_grounds_dir = proving_grounds_dir
end

AcceptanceSpecHelpers = Module.new do
  define_method :ruby do |filename|
    execute "ruby -I #{lib_dir} #{filename}", '', ENV
  end

  def strip_color(string)
    string.gsub(/\e\[\d+(;\d+)*?m/, '')
  end
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
