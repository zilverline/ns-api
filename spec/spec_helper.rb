require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'pry'

require 'mocha/api'
require 'webmock/rspec'
require 'timecop'

spec_helper = Pathname.new(__FILE__).realpath
lib_path  = File.expand_path("../../lib", spec_helper)
$:.unshift(lib_path)

##############################################################
# Configure rspec

RSpec.configure do |config|
  config.order = "random"

  config.after(:each) do
    Timecop.return # make sure timecop is disabled after each test
  end

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  unless config.inclusion_filter[:integration]
    p "Integration specs are DISABLED. To run integration specs only, use `rspec --tag integration`"
    config.filter_run_excluding :integration => true
  else
    p "Running integrtion specs ONLY."
  end

end

# END
##############################################################
$ROOT = File.expand_path("../", lib_path)

Dir.glob(File.join(lib_path, '/**/*.rb')).each do |file|
  require file
end

# helper methods for easier testing
def load_fixture(filename)
  File.read(File.join($ROOT, "spec/fixtures/#{filename}"))
end
