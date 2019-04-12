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
    expect(prices_url.url(date: Date.new(2013, 7, 12))).to eq("hostname?date=12072013")
  end

  it "uses from" do
    expected_from = "Amsterdam"
    expect(prices_url.url(from:"Amsterdam")).to eq("hostname?from=#{expected_from}")
  end

  it "uses to" do
    expected_to = "Purmerend"
    expect(prices_url.url(to:"Purmerend")).to eq("hostname?to=#{expected_to}")
  end

  it "uses via" do
    expected_via = "Zaandam"
    expect(prices_url.url(via:"Zaandam")).to eq("hostname?via=#{expected_via}")
  end

  it "uses any all variables for from/to/via" do
    expect(prices_url.url(from:"Purmerend",to: "Amsterdam", via:"Zaandam")).to eq("hostname?from=Purmerend&to=Amsterdam&via=Zaandam")
  end

  it "html encodes" do
    expect(prices_url.url(from:"Purmerend",to: "Amsterdam Centraal")).to eq("hostname?from=Purmerend&to=Amsterdam%20Centraal")
  end

  ANY_DATE = Date.new(2013, 8, 13)
  ANY_DATE_STR = "13082013"

end
