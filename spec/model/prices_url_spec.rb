require 'spec_helper'

describe PricesUrl do

  it "takes a fixed url as constructor argument" do
    PricesUrl.new("www.somehost.com")
  end

  it "raises an error when no url is given" do
    expect { PricesUrl.new(nil) }.to raise_error(PricesUrl::InvalidURL, "You must give an url, ie http://www.ns.nl/api")
  end

  it "assumes date is now, when not given" do
    @now = DateTime.new(2013, 6, 21)
    Timecop.freeze(@now)
    pricesUrl = PricesUrl.new("hostname")
    expected_date = "21062013"
    pricesUrl.to_s.should == "hostname?from=Amsterdam&to=Purmerend&date=#{expected_date}"
  end

end
