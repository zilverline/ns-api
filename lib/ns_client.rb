require 'pathname'
require 'time'
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

module NSYapi

  class Configuration
    attr_accessor :username, :password
  end

  def self.configure(configuration = NSYapi::Configuration.new)
    yield configuration if block_given?
    @@configuration = configuration
  end

  def self.configuration # :nodoc:
    @@configuration ||= NSYapi::Configuration.new
  end

  def self.client
    @client_instance = NSClient.new(configuration.username, configuration.password) unless @client_instance
    @client_instance
  end

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
    (xdoc/'/Stations/Station').each do |station|
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
    end
    result
  end

  def disruptions (query = nil)
    response = @client.get disruption_url(query)
    result = {planned: [], unplanned: []}
    xdoc = Nokogiri.XML(response.content)

    (xdoc/'/error').each do |error|
      message = (error/'./message').text
      raise InvalidStationNameError, message
    end

    (xdoc/'/Storingen').each { |disruption|

      (disruption/'Ongepland/Storing').each { |unplanned|
        unplanned_disruption = UnplannedDisruption.new
        unplanned_disruption.id = (unplanned/'./id').text
        unplanned_disruption.trip = (unplanned/'./Traject').text
        unplanned_disruption.reason = (unplanned/'./Reden').text
        unplanned_disruption.message = (unplanned/'./Bericht').text
        unplanned_disruption.datetime_string = (unplanned/'./Datum').text
        result[:unplanned] << unplanned_disruption
      }

      (disruption/'Gepland/Storing').each { |planned|
        planned_disruption = PlannedDisruption.new
        planned_disruption.id = (planned/'./id').text
        planned_disruption.trip = (planned/'./Traject').text
        planned_disruption.reason = (planned/'./Reden').text
        planned_disruption.advice = (planned/'./Advies').text
        planned_disruption.message = (planned/'./Bericht').text
        result[:planned] << planned_disruption
      }
    }
    result
  end

  def disruption_url(query)
    if query
      return "http://webservices.ns.nl/ns-api-storingen?station=#{query}"
    end
    "http://webservices.ns.nl/ns-api-storingen?"
  end

  class UnplannedDisruption
    attr_accessor :id, :trip, :reason, :message, :datetime_string
  end

  class PlannedDisruption
    attr_accessor :id, :trip, :reason, :advice, :message
  end

  class Station
    attr_accessor :code, :type, :land, :short_name, :name, :long_name, :uiccode, :synonyms, :lat, :long
  end

  class InvalidStationNameError < StandardError

  end

end