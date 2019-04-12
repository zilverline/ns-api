# frozen_string_literal: true

require 'ns_client'
require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'pry'

require 'mocha/api'
require 'webmock/rspec'
require 'timecop'

spec_helper = Pathname.new(__FILE__).realpath
lib_path = File.expand_path('../../lib', spec_helper)
$LOAD_PATH.unshift(lib_path)

##############################################################
# Configure rspec

RSpec.configure do |config|
  config.order = 'random'

  config.after(:each) do
    Timecop.return # make sure timecop is disabled after each test
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  if config.inclusion_filter[:integration]
    p 'Running integrtion specs ONLY.'
  else
    p 'Integration specs are DISABLED. To run integration specs only, use `rspec --tag integration`'
    config.filter_run_excluding integration: true
  end
end

# END
##############################################################

# helper methods for easier testing
def load_fixture(filename)
  File.read(File.join(File.dirname(__FILE__), "/fixtures/#{filename}"))
end
