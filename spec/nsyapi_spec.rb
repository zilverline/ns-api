require 'spec_helper'

describe NSYapi do

  context "Configuration" do

    it "should be configurable with a block" do
      NSYapi::configure do |config|
        config.username = "some-username"
        config.password = "some-password"
      end
      expect(NSYapi::configuration.username).to eq("some-username")
      expect(NSYapi::configuration.password).to eq("some-password")
    end

  end

  context "Singleton" do

    it "should create a singleton" do
      NSYapi::configure do |config|
        config.username = "some-username"
        config.password = "some-password"
      end

      client = NSYapi::client
      expect(client).to eq(NSYapi::client)
    end

  end


end