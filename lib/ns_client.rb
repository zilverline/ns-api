require 'pathname'
require 'time'
require 'httpi'
require 'nori'
require 'nokogiri'

require 'httpclient'

this = Pathname.new(__FILE__).realpath
lib_path = File.expand_path("..", this)
$:.unshift(lib_path)

$ROOT = File.expand_path("../", lib_path)

Dir.glob(File.join(lib_path, '/**/*.rb')).each do |file|
  require file
end

class NSClient

  def initialize(username, password)
    @client = HTTPClient.new
    @client.set_auth("http://webservices.ns.nl", username, password)
  end

  def stations
    response = @client.get "http://webservices.ns.nl/ns-api-stations-v2"
    result = []
    xdoc = Nokogiri.XML(response.content)
    (xdoc/'/Stations/Station').each { |station|
      s = Station.new
      s.code = (station/'./Code').text
      s.type = (station/'./Type').text
      s.land = (station/'./Land').text
      s.short_name = (station/'./Namen/Kort').text
      s.name = (station/'./Namen/Middel').text
      s.long_name = (station/'./Namen/Lang').text
      s.lat = (station/'./Lat').text
      s.long = (station/'./Lon').text
      s.uiccode = (station/'./UICCode').text
      result << s
    }
    result
  end

  class Station
    attr_accessor :code, :type, :land, :short_name, :name, :long_name, :uiccode, :synonyms, :lat, :long
  end

end