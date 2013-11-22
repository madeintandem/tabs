require "spec_helper"
require File.expand_path("../../../support/custom_resolutions", __FILE__)

describe Tabs::Config do
  context "#decimal_precision" do

  	before do
  		@precision = Tabs::Config.decimal_precision
  	end

  	after do
  		Tabs::Config.decimal_precision = @precision
  	end

  	it "should set/get the decimal precision" do
  	  Tabs::Config.decimal_precision = 4
  	  expect(Tabs::Config.decimal_precision).to eq(4)
  	end
  end

  context "#register_resolution" do
  	it "should register a resolution" do
	  	Tabs::Resolution.register(WellFormedResolution)
	  	expect(Tabs::Resolution.all).to include(:seconds)
  	end
  end

  context "#unregister_resolution" do
  	it "should unregister a resolution" do
  		Tabs::Resolution.unregister(:minute)
  		expect(Tabs::Resolution.all).to_not include(:minute)
  	end
  end

  context "#set_expirations" do

    after do
      Tabs::Config.reset_expirations
    end

    it "should allow multiple resolutions to be expired" do
      Tabs::Config.set_expirations({ minute: 1.day, hour: 1.week })
      expect(Tabs::Config.expiration_settings[:minute]).to eq(1.day)
      expect(Tabs::Config.expiration_settings[:hour]).to eq(1.week)
    end

    it "should raise ResolutionMissingError if expiration passed in for invalid resolution" do
      expect{ Tabs::Config.set_expirations({ missing_resolution: 1.day }) }
        .to raise_error(Tabs::ResolutionMissingError)
    end

  end

  context "#prefix" do
    it "should allow custom prefix for tabs keys" do
      Tabs::Config.prefix = "rspec"
      expect(Tabs::Config.prefix).to eq("rspec")
    end
  end
end
