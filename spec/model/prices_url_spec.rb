require 'spec_helper'

describe PricesUrl do

  it "takes a fixed url as constructor argument" do
    PricesUrl.new("www.somehost.com")
  end

  it "raises an error when no url is given" do
    expect { PricesUrl.new(nil) }.to raise_error(PricesUrl::InvalidURL, "You must give an url, ie http://www.ns.nl/api")
  end

  let(:prices_url) { PricesUrl.new("hostname") }

  it "uses given date" do
    prices_url.url(date: Date.new(2013, 7, 12)).should == "hostname?date=12072013"
  end

  it "uses from" do
    expected_from = "Amsterdam"
    prices_url.url(from:"Amsterdam").should == "hostname?from=#{expected_from}"
  end

  it "uses to" do
    expected_to = "Purmerend"
    prices_url.url(to:"Purmerend").should == "hostname?to=#{expected_to}"
  end

  it "uses via" do
    expected_via = "Zaandam"
    prices_url.url(via:"Zaandam").should == "hostname?via=#{expected_via}"
  end

  it "uses any all variables for from/to/via" do
    prices_url.url(from:"Purmerend",to: "Amsterdam", via:"Zaandam").should == "hostname?from=Purmerend&to=Amsterdam&via=Zaandam"
  end

  it "html encodes" do
    prices_url.url(from:"Purmerend",to: "Amsterdam Centraal").should == "hostname?from=Purmerend&to=Amsterdam%20Centraal"
  end

  ANY_DATE = Date.new(2013, 8, 13)
  ANY_DATE_STR = "13082013"

end
