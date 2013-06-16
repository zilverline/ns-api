require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'httpclient'

require 'mocha/api'
require 'webmock/rspec'


spec_helper = Pathname.new(__FILE__).realpath
lib_path  = File.expand_path("../../lib", spec_helper)
$:.unshift(lib_path)

$ROOT = File.expand_path("../", lib_path)

Dir.glob(File.join(lib_path, '/**/*.rb')).each do |file|
  require file
end

def load_fixture(filename)
  File.read(File.join($ROOT, "spec/fixtures/#{filename}"))
end
