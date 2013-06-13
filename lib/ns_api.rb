require 'time'
require 'httpi'
require 'nori'

this = Pathname.new(__FILE__).realpath
lib_path = File.expand_path("..", this)
$:.unshift(lib_path)

$ROOT = File.expand_path("../", lib_path)

Dir.glob(File.join(lib_path, '/**/*.rb')).each do |file|
  require file
end

module NSAPI

  class << self

    def stations
      raise "Implement me!"
    end

  end

end