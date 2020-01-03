# frozen_string_literal: true

require 'pathname'
require 'time'
require 'nori'
require 'nokogiri'
require 'rest-client'
require 'addressable/uri'

this = Pathname.new(__FILE__).realpath
lib_path = File.expand_path('..', this)
$LOAD_PATH.unshift(lib_path)

Dir.glob(File.join(lib_path, '/**/*.rb')).sort.each do |file|
  require file
end

module NSYapi
  class Configuration
    attr_accessor :username, :password, :configuration
  end

  def self.configure(configuration = NSYapi::Configuration.new)
    yield configuration if block_given?
    @configuration = configuration
  end

  def self.configuration # :nodoc:
    @configuration ||= NSYapi::Configuration.new
  end

  def self.client
    @client_instance ||= NSClient.new(configuration.username, configuration.password)
    @client_instance
  end
end

class NSClient
  attr_accessor :last_received_raw_xml, :last_received_corrected_xml, :username, :password

  def initialize(username, password)
    @username = username
    @password = password
    @prices_url = PricesUrl.new('https://webservices.ns.nl/ns-api-prijzen-v3')
    @last_received_raw_xml = ''
    @last_received_corrected_xml = ''
  end

  def stations
    parse_stations(get_xml('https://webservices.ns.nl/ns-api-stations-v2'))
  end

  def stations_short
    parse_stations_as_map(get_xml('https://webservices.ns.nl/ns-api-stations-v2'))
  end

  def disruptions(query = nil)
    response_xml = get_xml(disruption_url(query))
    raise_error_when_response_is_error(response_xml)
    parse_disruptions(response_xml)
  end

  def prices(opts = { from: nil, to: nil, via: nil, date: nil })
    validate_prices(opts)
    response_xml = get_xml(@prices_url.url(opts))
    raise_error_when_response_is_error(response_xml)
    parse_prices(response_xml)
  end

  def validate_price_parameters(opts)
    raise MissingParameter, 'from and to station is required' if opts[:from].nil? && opts[:to].nil?
    raise MissingParameter, 'from station is required' unless opts[:from]
    raise MissingParameter, 'to station is required' unless opts[:to]
  end

  def validate_prices(opts)
    validate_price_parameters(opts)

    return unless opts[:from] == opts[:to]

    raise SameDestinationError,
          "from (#{opts[:from]}) and to (#{opts[:to]}) parameters should not be equal"
  end

  def parse_prices(response_xml)
    prices_response = PricesResponse.new
    (response_xml / '/VervoerderKeuzes/VervoerderKeuze').each do |transporter|
      prices_response.tariff_units = (transporter / './Tariefeenheden').text.to_i

      (transporter / 'ReisType').each do |travel_type|
        prices = parse_travel_type(travel_type)

        name = travel_type.attr('name')
        prices_response.products[name] = prices
      end
    end
    prices_response
  end

  def parse_travel_type(travel_type)
    prices = []

    (travel_type / 'ReisKlasse').each do |travel_class|
      (travel_class / 'Korting/Kortingsprijs').each do |price_element|
        product_price = ProductPrice.new
        product_price.discount = price_element.attr('name')
        product_price.train_class = travel_class.attr('klasse')
        product_price.amount = price_element.attr('prijs').tr(',', '.').to_f
        prices << product_price
      end
    end

    prices
  end

  def parse_stations(response_xml)
    result = []
    (response_xml / '/Stations/Station').each do |station|
      result << parse_station(station)
    end
    result
  end

  def parse_station(station)
    s = Station.new
    s.code = parse_station_field(station, './Code')
    s.type = parse_station_field(station, './Type')
    s.country = parse_station_field(station, './Land')
    s.short_name = parse_station_field(station, './Namen/Kort')
    s.name = parse_station_field(station, './Namen/Middel')
    s.long_name = parse_station_field(station, './Namen/Lang')
    s.lat = parse_station_field(station, './Lat')
    s.long = parse_station_field(station, './Lon')
    s.uiccode = parse_station_field(station, './UICCode')
    s
  end

  def parse_station_field(station, field)
    (station / field).text
  end

  def parse_stations_as_map(response_xml)
    result = {}
    (response_xml / '/Stations/Station').each do |station|
      code = (station / './Code').text
      name = (station / './Namen/Middel').text
      country = (station / './Land').text
      result[code] = [name, country]
    end
    result
  end

  def parse_disruptions(response_xml)
    result = { planned: [], unplanned: [] }
    (response_xml / '/Storingen').each do |disruption|
      (disruption / 'Ongepland/Storing').each do |unplanned|
        result[:unplanned] << parse_unplanned_disruption(unplanned)
      end

      (disruption / 'Gepland/Storing').each do |planned|
        result[:planned] << parse_planned_disruption(planned)
      end
    end
    result
  end

  def parse_unplanned_disruption(disruption)
    result = UnplannedDisruption.new
    result.id = (disruption / './id').text
    result.trip = (disruption / './Traject').text
    result.reason = (disruption / './Reden').text
    result.message = (disruption / './Bericht').text
    result.datetime_string = (disruption / './Datum').text
    result.cause = (disruption / './Oorzaak').text
    result
  end

  def parse_planned_disruption(disruption)
    result = PlannedDisruption.new
    result.id = (disruption / './id').text
    result.trip = (disruption / './Traject').text
    result.reason = (disruption / './Reden').text
    result.advice = (disruption / './Advies').text
    result.message = (disruption / './Bericht').text
    result.cause = (disruption / './Oorzaak').text
    result
  end

  def raise_error_when_response_is_error(xdoc)
    (xdoc / '/error').each do |error|
      message = (error / './message').text
      raise InvalidStationNameError, message
    end
  end

  def get_xml(url)
    response = RestClient::Request.new(url: url, user: username, password: password, method: :get).execute
    @last_received_raw_xml = response.body
    @last_received_corrected_xml = remove_unwanted_whitespace(@last_received_raw_xml)
    begin
      Nokogiri.XML(@last_received_corrected_xml) do |config|
        config.options = Nokogiri::XML::ParseOptions::STRICT
      end
    rescue Nokogiri::XML::SyntaxError => e
      raise UnparseableXMLError, e
    end
  end

  def remove_unwanted_whitespace(content)
    content.gsub %r{<\s*(/?)\s*?([a-zA-Z0-9]*)\s*([a-zA-Z0-9]*)\s*>}, '<\1\2\3>'
  end

  def disruption_url(query)
    return "https://webservices.ns.nl/ns-api-storingen?station=#{query}" if query

    'https://webservices.ns.nl/ns-api-storingen?actual=true'
  end

  class PricesResponse
    attr_accessor :tariff_units, :products

    def initialize
      @products = {}
      @tariff_units = 0
    end

    def enkele_reis
      products['Enkele reis']
    end

    def dagretour
      products['Retour']
    end
  end

  class ProductPrice
    attr_accessor :discount, :train_class, :amount
    DISCOUNT_MAP ||= {
      '20% korting' => 'reductie_20',
      '40% korting' => 'reductie_40'
    }.freeze

    def type
      DISCOUNT_MAP.fetch(discount, discount)
    end
  end

  class UnplannedDisruption
    attr_accessor :id, :trip, :reason, :message, :datetime_string, :cause
  end

  class PlannedDisruption
    attr_accessor :id, :trip, :reason, :advice, :message, :cause
  end

  class Station
    attr_accessor :code, :type, :country, :short_name, :name, :long_name, :uiccode, :synonyms, :lat, :long
  end

  class InvalidStationNameError < StandardError
  end

  class MissingParameter < StandardError
  end

  class UnparseableXMLError < StandardError
  end

  class SameDestinationError < StandardError
  end
end
