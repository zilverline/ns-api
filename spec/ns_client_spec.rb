require 'spec_helper'

describe NSClient do

  before :each do
    @client = NSClient.new("username", "password")
  end

  context "Stations" do

    context "with valid xml" do

      before :each do
        stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-stations-v2", load_fixture('stations.xml')
      end

      it "should return all stations" do
        stations = @client.stations
        stations.size.should == 620
      end

      it "should return expected first station from list" do
        stations = @client.stations
        first_station = stations.first
        first_station.class.should == NSClient::Station
        first_station.type.should == "knooppuntIntercitystation"
        first_station.code.should == "HT"
        first_station.short_name.should == "H'bosch"
        first_station.name.should == "'s-Hertogenbosch"
        first_station.long_name.should == "'s-Hertogenbosch"
        first_station.country.should == "NL"
        first_station.uiccode.should == "8400319"
        first_station.lat.should == "51.69048"
        first_station.long.should == "5.29362"
      end

      it "should retrieve a convenient hash with usable station names and codes for prices usage" do
        stations = @client.stations_short
        stations.size.should == 620
        stations["HT"].should == ["'s-Hertogenbosch", "NL"]
      end

    end

    describe "invalid stations xml" do

      before :each do
        stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-stations-v2", load_fixture('stations_list_with_invalid_new_lines.xml')
      end

      it "should return all stations" do
        stations = @client.stations
        stations.size.should == 2
      end

    end

  end

  context "Disruptions" do

    it "should retrieve planned and unplanned disruptions" do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('disruptions.xml')
      disruptions = @client.disruptions
      disruptions.size.should == 2
      disruptions[:planned].size.should == 1
      disruptions[:unplanned].size.should == 1
    end

    it "should retrieve expected planned disruption" do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('disruptions.xml')
      disruptions = @client.disruptions
      disruptions.size.should == 2
      planned_disruption = disruptions[:planned].first
      planned_disruption.class.should == NSClient::PlannedDisruption

      planned_disruption.id.should == "2010_almo_wp_18_19dec"
      planned_disruption.trip.should == "Almere Oostvaarders-Weesp/Naarden-Bussum"
      planned_disruption.reason.should == "Beperkt treinverkeer, businzet en/of omreizen, extra reistijd 15-30 min."
      planned_disruption.advice.should == "Maak gebruik van de overige treinen of de bussen: reis tussen Weesp en Almere Centrum met de NS-bus in
        plaats van de trein tussen Almere Centrum en Lelystad Centrum rijden vier Sprinters per uur reis tussen Almere
        Muziekwijk en Naarden-Bussum via Weesp"
      planned_disruption.message.should == "Test message"
      planned_disruption.cause.should == "oorzaak"
    end

    it "should retrieve expected unplanned disruption" do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('disruptions.xml')
      disruptions = @client.disruptions
      disruptions.size.should == 2
      unplanned_disruption = disruptions[:unplanned].first
      unplanned_disruption.class.should == NSClient::UnplannedDisruption

      unplanned_disruption.id.should == "prio-13345"
      unplanned_disruption.trip.should == "'s-Hertogenbosch-Nijmegen"
      unplanned_disruption.reason.should == "beperkingen op last van de politie"
      unplanned_disruption.cause.should == "oorzaak"
      unplanned_disruption.message.should == "Another test message"
      unplanned_disruption.datetime_string == "2010-12-16T11:16:00+0100" #intentional, give raw data. Let user parse if needed.
    end

    it "should not return disruption when empty in response" do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-storingen?actual=true", load_fixture('no_disruptions.xml')
      disruptions = @client.disruptions
      disruptions.size.should == 2
      disruptions[:planned].size.should == 0
      disruptions[:unplanned].size.should == 0
    end

    describe "for a specific station" do

      it "should retrieve disruptions for station name" do
        # ie, for Amsterdam only (http://webservices.ns.nl/ns-api-storingen?station=Amsterdam)
        stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-storingen?station=Amsterdam", load_fixture('disruptions_amsterdam.xml')
        disruptions = @client.disruptions "Amsterdam"
        disruptions.size.should == 2
        disruptions[:planned].size.should == 4
        disruptions[:unplanned].size.should == 0
      end

      it "should raise an error when using invalid station name" do
        stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-storingen?station=bla", load_fixture('disruption_invalid_station_name.xml')
        expect { @client.disruptions "bla" }.to raise_error(NSClient::InvalidStationNameError, "Could not find a station with name 'bla'")
      end
    end


  end

  context "Prices" do

    it "should retrieve prices for a trip" do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-prijzen-v2?from=Purmerend&to=Amsterdam&via=Zaandam&date=17062013", load_fixture('prices.xml')
      date = Date.strptime('17-06-2013', '%d-%m-%Y')
      response = @client.prices from: "Purmerend", to: "Amsterdam", via: "Zaandam", date: date
      response.class.should == NSClient::PricesResponse
      response.tariff_units.should == 10
      response.products.size.should == 2

      response.enkele_reis.size.should == 6
      response.dagretour.size.should == 6
    end

    it "should retrieve expected price data" do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-prijzen-v2?from=Purmerend&to=Amsterdam&via=Zaandam&date=17062013", load_fixture('prices.xml')
      date = Date.strptime('17-06-2013', '%d-%m-%Y')
      response = @client.prices from: "Purmerend", to: "Amsterdam", via: "Zaandam", date: date
      response.class.should == NSClient::PricesResponse
      response.tariff_units.should == 10
      response.products.size.should == 2

      assert_price(response.enkele_reis[0], "vol tarief", "2", 2.4)
      assert_price(response.enkele_reis[1], "reductie_20", "2", 1.90)
      assert_price(response.enkele_reis[2], "reductie_40", "2", 1.40)
      assert_price(response.enkele_reis[3], "vol tarief", "1", 4.10)
      assert_price(response.enkele_reis[4], "reductie_20", "1", 3.3)
      assert_price(response.enkele_reis[5], "reductie_40", "1", 2.5)
    end

    it "should raise error when from is not given" do
      expect {
        @client.prices from: nil, to: "Amsterdam"
      }.to raise_error(NSClient::MissingParameter, "from station is required")
    end

    it "should raise an error when from is not a valid station name" do
      date = Date.strptime('17-06-2013', '%d-%m-%Y')
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-prijzen-v2?from=Amsterdam&to=Purmerend&date=17062013", load_fixture('prices_invalid_station_name.xml')
      expect {
        @client.prices from: "Amsterdam", to: "Purmerend", date: date
      }.to raise_error(NSClient::InvalidStationNameError, "'Amsterdam' is not a valid station name")
    end

    it "should raise error when to is not given" do
      expect {
        @client.prices from: "Purmerend", to: nil
      }.to raise_error(NSClient::MissingParameter, "to station is required")
    end

    it "should raise error complaining about from and to missing when both not given" do
      expect {
        @client.prices from: nil, to: nil
      }.to raise_error(NSClient::MissingParameter, "from and to station is required")
    end

  end

  def assert_price(element, expected_type, expected_train_class, expected_amount)
    element.type.should == expected_type
    element.train_class.should == expected_train_class
    element.amount.should == expected_amount
  end

  def stub_ns_client_request(url, response)
    # headers based on "username", "password"
    stub_request(:get, url).
        with(:headers => {'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ='}).
        to_return(:status => 200, :body => response, :headers => {})
  end

end
