require 'spec_helper'

describe NSClient do

  before :each do
    @nsapi = NSClient.new("username", "password")
  end

  it "should return all stations from NS" do
    stub_ns_client_request "http://username:password@webservices.ns.nl/ns-api-stations-v2", load_fixture('ns_stations.xml')
    stations = @nsapi.stations
    stations.size.should == 620
  end

  def stub_ns_client_request(url, response)
    stub_request(:get, url).
        with(:headers => {'Authorization'=>'Basic dXNlcm5hbWU6cGFzc3dvcmQ='}).
        to_return(:status => 200, :body => response, :headers => {})
  end

  def load_fixture(filename)
    File.read(File.join($ROOT, "spec/fixtures/#{filename}"))
  end

end
