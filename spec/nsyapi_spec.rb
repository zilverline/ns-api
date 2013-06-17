require 'spec_helper'

describe NSYapi do

  context "Configuration" do

    it "should be configurable with a block" do
      NSYapi::configure do |config|
        config.username = "some-username"
        config.password = "some-password"
      end
      NSYapi::configuration.username.should == "some-username"
      NSYapi::configuration.password.should == "some-password"
    end

  end

  context "Singleton" do

    it "should create a singleton" do
      NSYapi::configure do |config|
        config.username = "some-username"
        config.password = "some-password"
      end

      client = NSYapi::client
      client.should == NSYapi::client
    end

  end


end