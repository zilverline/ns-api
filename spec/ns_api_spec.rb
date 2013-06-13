require 'spec_helper'

describe NSAPI do

  it "should retrieve stations" do
    # stub response...
    expected = []
    NSAPI::stations.should == expected
  end

end
