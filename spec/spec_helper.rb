require 'simplecov'
SimpleCov.start 'rails'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'interface_enforcement'

Dir.glob(File.join(File.dirname(__FILE__), 'support', '**', '*.rb')).each do |f|
  require f
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
