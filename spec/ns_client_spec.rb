require 'spec_helper'

describe NSClient do

  before :each do
    @client = NSClient.new("username", "password")
  end

  context "Stations" do

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
      first_station.land.should == "NL"
      first_station.uiccode.should == "8400319"
      first_station.lat.should == "51.69048"
      first_station.long.should == "5.29362"
    end

  end

  context "Disruptions" do
    it "should retrieve all disruptions" do
      @client.disruptions.should == []
    end
  end

  context "Prices" do
    xit "should retrieve prices for a trip"
  end

  def stub_ns_client_request(url, response)
    # headers based on "username", "password"
    stub_request(:get, url).
        with(:headers => {'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ='}).
        to_return(:status => 200, :body => response, :headers => {})
  end

end
