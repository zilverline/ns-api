#encoding: utf-8
require 'spec_helper'
require 'yaml'

describe NSClient do

  let! (:client) { NSClient.new("username", "password") }

  context "Stations" do

    context "with valid xml" do

      before :each do
        stub_ns_client_request "http://webservices.ns.nl/ns-api-stations-v2", load_fixture('stations.xml')
      end

      it "should return all stations" do
        stations = client.stations
        expect(stations.size).to eq(620)
      end

      it "should return expected first station from list" do
        stations = client.stations
        first_station = stations.first
        expect(first_station.class).to eq(NSClient::Station)
        expect(first_station.type).to eq("knooppuntIntercitystation")
        expect(first_station.code).to eq("HT")
        expect(first_station.short_name).to eq("H'bosch")
        expect(first_station.name).to eq("'s-Hertogenbosch")
        expect(first_station.long_name).to eq("'s-Hertogenbosch")
        expect(first_station.country).to eq("NL")
        expect(first_station.uiccode).to eq("8400319")
        expect(first_station.lat).to eq("51.69048")
        expect(first_station.long).to eq("5.29362")
      end

      it "should retrieve a convenient hash with usable station names and codes for prices usage" do
        stations = client.stations_short
        expect(stations.size).to eq(620)
        expect(stations["HT"]).to eq(["'s-Hertogenbosch", "NL"])
      end


    end

    describe "integration specs", :integration do

      # requires a credentials.yml in spec/fixtures with a username and password
      it "should parse live data correctly", focus: true do
        found_error = false
        WebMock.allow_net_connect!
        #while (!found_error) do
          credentials = YAML.load_file(File.join($ROOT, "spec/fixtures/credentials.yml"))
          client = NSClient.new(credentials["username"], credentials["password"])
          stations = client.stations
          station = stations.find { |s| s.code == "OETZ" }
          expected_count = 613
          found_error = !(station.code == "OETZ" && station.country == "A" && station.name == "Ötztal" && stations.count == expected_count)

          if found_error
            f = File.open("/tmp/ns_stations_without_oztal.xml", "w")
            f.write(client.last_received_raw_xml)
            f.close
            raise "Could not find staiton with code 'OETZ', see /tmp/ns_stations_without_oztal.xml" if station.blank?
            raise "Found station, but with different properties or size differs? Country should be 'A' but is #{station.country}, station name should be 'Ötztal' but is #{station.name}, and the count should be #{expected_count}. (count is #{stations.count}) see /tmp/ns_stations_without_oztal.xml"
          else
            p "Test went OK, #{stations.count} stations found"
          end
        #end
        # remove the loop to constantly check NS if we are doubting their source
      end

    end

  end

  describe "invalid stations xml" do

    context "with only newlines/spaces we can fix" do

      it "should return all stations" do
        stub_ns_client_request "http://webservices.ns.nl/ns-api-stations-v2", load_fixture('stations_list_with_invalid_new_lines.xml')
        stations = client.stations
        expect(stations.size).to eq(2)
      end

      {
          "< Code>" => "<Code>",
          "< Code >" => "<Code>",
          "< Code    >" => "<Code>",
          "<     Code>" => "<Code>",
          "</   Code>" => "</Code>",
          "<  /   Code>" => "</Code>",
          "</  Code  >" => "</Code>",
          "</ Code  >" => "</Code>",
          "</\n\nCode  >" => "</Code>",
          "</\r\tCode\n>" => "</Code>",
          "</Co\nde\n>" => "</Code>",
      }.each do |k, v|
        it "removes unwanted whitespace from #{k} , expecting #{v} (remove_unwanted_whitespace)" do
          expect(client.remove_unwanted_whitespace(k)).to eq v
        end
      end

    end

    context "with mangled XML we cannot / won't fix" do

      it "raises an error when xml is unparseable" do
        stub_ns_client_request "http://webservices.ns.nl/ns-api-stations-v2", load_fixture('stations_list_mangled.xml')
        expect { client.stations }.to raise_error(NSClient::UnparseableXMLError)
      end

    end

  end

  context "Disruptions" do

    it "should retrieve planned and unplanned disruptions" do
      stub_ns_client_request "http://webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('disruptions.xml')
      disruptions = client.disruptions
      expect(disruptions.size).to eq(2)
      expect(disruptions[:planned].size).to eq(1)
      expect(disruptions[:unplanned].size).to eq(1)
    end

    it "should retrieve expected planned disruption" do
      stub_ns_client_request "http://webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('disruptions.xml')
      disruptions = client.disruptions
      expect(disruptions.size).to eq(2)
      planned_disruption = disruptions[:planned].first
      expect(planned_disruption.class).to eq(NSClient::PlannedDisruption)

      expect(planned_disruption.id).to eq("2010_almo_wp_18_19dec")
      expect(planned_disruption.trip).to eq("Almere Oostvaarders-Weesp/Naarden-Bussum")
      expect(planned_disruption.reason).to eq("Beperkt treinverkeer, businzet en/of omreizen, extra reistijd 15-30 min.")
      expect(planned_disruption.advice).to eq("Maak gebruik van de overige treinen of de bussen: reis tussen Weesp en Almere Centrum met de NS-bus in
        plaats van de trein tussen Almere Centrum en Lelystad Centrum rijden vier Sprinters per uur reis tussen Almere
        Muziekwijk en Naarden-Bussum via Weesp")
      expect(planned_disruption.message).to eq("Test message")
      expect(planned_disruption.cause).to eq("oorzaak")
    end

    it "should retrieve expected unplanned disruption" do
      stub_ns_client_request "http://webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('disruptions.xml')
      disruptions = client.disruptions
      expect(disruptions.size).to eq(2)
      unplanned_disruption = disruptions[:unplanned].first
      expect(unplanned_disruption.class).to eq(NSClient::UnplannedDisruption)

      expect(unplanned_disruption.id).to eq("prio-13345")
      expect(unplanned_disruption.trip).to eq("'s-Hertogenbosch-Nijmegen")
      expect(unplanned_disruption.reason).to eq("beperkingen op last van de politie")
      expect(unplanned_disruption.cause).to eq("oorzaak")
      expect(unplanned_disruption.message).to eq("Another test message")
      unplanned_disruption.datetime_string == "2010-12-16T11:16:00+0100" #intentional, give raw data. Let user parse if needed.
    end

    it "should not return disruption when empty in response" do
      stub_ns_client_request "http://webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('no_disruptions.xml')
      disruptions = client.disruptions
      expect(disruptions.size).to eq(2)
      expect(disruptions[:planned].size).to eq(0)
      expect(disruptions[:unplanned].size).to eq(0)
    end

    describe "for a specific station" do

      it "should retrieve disruptions for station name" do
        # ie, for Amsterdam only (http://webservices.ns.nl/ns-api-storingen?station=Amsterdam)
        stub_ns_client_request "http://webservices.ns.nl/ns-api-storingen?station=Amsterdam", load_fixture('disruptions_amsterdam.xml')
        disruptions = client.disruptions "Amsterdam"
        expect(disruptions.size).to eq(2)
        expect(disruptions[:planned].size).to eq(4)
        expect(disruptions[:unplanned].size).to eq(0)
      end

      it "should raise an error when using invalid station name" do
        stub_ns_client_request "http://webservices.ns.nl/ns-api-storingen?station=bla", load_fixture('disruption_invalid_station_name.xml')
        expect { client.disruptions "bla" }.to raise_error(NSClient::InvalidStationNameError, "Could not find a station with name 'bla'")
      end
    end


  end

  context "Prices" do

    it "should retrieve prices for a trip" do
      stub_ns_client_request "http://webservices.ns.nl/ns-api-prijzen-v3?from=Rotterdam&to=Glanerbrug&date=17062013", load_fixture('prices.xml')
      date = Date.strptime('17-06-2013', '%d-%m-%Y')
      response = client.prices from: "Rotterdam", to: "Glanerbrug", date: date
      expect(response.class).to eq(NSClient::PricesResponse)
      expect(response.tariff_units).to eq(205)
      expect(response.products.size).to eq(2)

      expect(response.enkele_reis.size).to eq(6)
      expect(response.dagretour.size).to eq(6)
    end

    it "should retrieve expected price data" do
      stub_ns_client_request "http://webservices.ns.nl/ns-api-prijzen-v3?from=Rotterdam&to=Glanerbrug&date=17062013", load_fixture('prices.xml')
      date = Date.strptime('17-06-2013', '%d-%m-%Y')
      response = client.prices from: "Rotterdam", to: "Glanerbrug", date: date
      expect(response.class).to eq(NSClient::PricesResponse)
      expect(response.tariff_units).to eq(205)
      expect(response.products.size).to eq(2)

      assert_price(response.enkele_reis[0], "vol tarief", "1", 41.5)
      assert_price(response.enkele_reis[1], "reductie_20", "1", 33.2)
      assert_price(response.enkele_reis[2], "reductie_40", "1", 24.9)
      assert_price(response.enkele_reis[3], "vol tarief", "2", 24.4)
      assert_price(response.enkele_reis[4], "reductie_20", "2", 19.5)
      assert_price(response.enkele_reis[5], "reductie_40", "2", 14.6)
    end

    it "should raise error when from is not given" do
      expect {
        client.prices from: nil, to: "Amsterdam"
      }.to raise_error(NSClient::MissingParameter, "from station is required")
    end

    it "should raise an error when from is not a valid station name" do
      date = Date.strptime('17-06-2013', '%d-%m-%Y')
      stub_ns_client_request "http://webservices.ns.nl/ns-api-prijzen-v3?from=Amsterdam&to=Purmerend&date=17062013", load_fixture('prices_invalid_station_name.xml')
      expect {
        client.prices from: "Amsterdam", to: "Purmerend", date: date
      }.to raise_error(NSClient::InvalidStationNameError, "'Amsterdam' is not a valid station name")
    end

    it "should raise error when to is not given" do
      expect {
        client.prices from: "Purmerend", to: nil
      }.to raise_error(NSClient::MissingParameter, "to station is required")
    end

    it "should raise error complaining about from and to missing when both not given" do
      expect {
        client.prices from: nil, to: nil
      }.to raise_error(NSClient::MissingParameter, "from and to station is required")
    end

    it "should raise an error when from and to are the same" do
      expect {
        client.prices from: 'AMA', to: 'AMA'
      }.to raise_error(NSClient::SameDestinationError, "from (AMA) and to (AMA) parameters should not be equal")
    end

  end

  def assert_price(element, expected_type, expected_train_class, expected_amount)
    expect(element.type).to eq(expected_type)
    expect(element.train_class).to eq(expected_train_class)
    expect(element.amount).to eq(expected_amount)
  end

  def stub_ns_client_request(url, response)
    # headers based on "username", "password"
    stub_request(:get, url).
        with(headers: {'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ='}).
        to_return(status: 200, body: response, headers: {})
  end
end
