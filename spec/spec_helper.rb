require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!


require 'httpclient'

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
