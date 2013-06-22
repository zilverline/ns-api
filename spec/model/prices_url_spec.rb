require 'spec_helper'

describe PricesUrl do

  it "takes a fixed url as constructor argument" do
    PricesUrl.new("www.somehost.com")
  end

  it "raises an error when no url is given" do
    expect { PricesUrl.new(nil) }.to raise_error(PricesUrl::InvalidURL, "You must give an url, ie http://www.ns.nl/api")
  end

  let(:prices_url) { PricesUrl.new("hostname") }

  it "assumes date is now, when not given" do
    Timecop.freeze(DateTime.new(2013, 6, 21))
    expected_date = "21062013" #DDMMYYYY
    prices_url.url.should == "hostname?from=&to=&date=#{expected_date}"
  end

  it "uses given date" do
    prices_url.url(date: Date.new(2013, 7, 12)).should == "hostname?from=&to=&date=12072013"
  end

  it "uses from" do
    expected_from = "Amsterdam"
    prices_url.url(from:"Amsterdam", date: ANY_DATE).should == "hostname?from=#{expected_from}&to=&date=#{ANY_DATE_STR}"
  end

  it "uses to" do
    expected_to = "Purmerend"
    prices_url.url(to:"Purmerend", date: ANY_DATE).should == "hostname?from=&to=#{expected_to}&date=#{ANY_DATE_STR}"
  end

  it "uses via" do
    expected_via = "Zaandam"
    prices_url.url(via:"Zaandam", date: ANY_DATE).should == "hostname?from=&to=&via=#{expected_via}&date=#{ANY_DATE_STR}"
  end

  it "uses any combination of from/to/via" do
    prices_url.url(from:"Purmerend",to: "Amsterdam", via:"Zaandam", date: ANY_DATE).should == "hostname?from=Purmerend&to=Amsterdam&via=Zaandam&date=#{ANY_DATE_STR}"
    prices_url.url(from:"Purmerend",to: "Amsterdam", via:"Zaandam", date: ANY_DATE).should == "hostname?from=Purmerend&to=Amsterdam&via=Zaandam&date=#{ANY_DATE_STR}"
    prices_url.url(from:"Purmerend",to: "Amsterdam", via:"Zaandam", date: ANY_DATE).should == "hostname?from=Purmerend&to=Amsterdam&via=Zaandam&date=#{ANY_DATE_STR}"
    prices_url.url(from:"Purmerend",to: "Amsterdam", via:"Zaandam", date: ANY_DATE).should == "hostname?from=Purmerend&to=Amsterdam&via=Zaandam&date=#{ANY_DATE_STR}"
  end

  ANY_DATE = Date.new(2013, 8, 13)
  ANY_DATE_STR = "13082013"

end
