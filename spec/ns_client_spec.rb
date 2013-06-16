require 'spec_helper'

describe NSClient do

  before :each do
    @nsclient = NSClient.new("username", "password")
  end

  context "Fetching stations from NS" do

    before :each do
      stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-stations-v2", load_fixture('ns_stations.xml')
    end

    it "should return all stations" do
      stations = @nsclient.stations
      stations.size.should == 620
    end

    it "should return expected first station from list" do
      stations = @nsclient.stations
      first_station = stations.first
      first_station.class.should == NSClient::Station
      first_station.type.should == "knooppuntIntercitystation"
      first_station.code.should == "HT"
      first_station.short_name == "H'bosch"
      first_station.name == "'s-Hertogenbosch"
      first_station.long_name == "'s-Hertogenbosch"
      first_station.land == "NL"
      first_station.uiccode == "8400319"
      first_station.lat == "51.69048"
      first_station.long == "5.29362"
    end

  end



def stub_ns_client_request(url, response)
  stub_request(:get, url).
      with(:headers => {'Authorization' => 'Basic dXNlcm5hbWU6cGFzc3dvcmQ='}).
      to_return(:status => 200, :body => response, :headers => {})
end

def load_fixture(filename)
  File.read(File.join($ROOT, "spec/fixtures/#{filename}"))
end

end
