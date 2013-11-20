require "spec_helper"
require File.expand_path("../../../support/custom_resolutions", __FILE__)

describe Tabs::Resolution do
  describe "#register" do
    it "registers a new resolution" do
      Tabs::Resolution.register(:test, Tabs::Resolutions::Minute)
      expect(Tabs::Resolution.all).to include :test
    end

    context "with a custom resolution" do
      it "does not return nil" do
        expect(WellFormedResolution.serialize(Time.now)).to_not be_nil
      end

      it "gets stats for custom resolution" do
        Tabs::Resolution.register(:seconds, WellFormedResolution)
        Timecop.freeze(Time.now)

        Tabs.increment_counter("foo")
        expect(Tabs.get_stats("foo", (Time.now - 5.seconds..Time.now), :seconds).values.size).to eq(6)
      end

      it "raises an error when method not implemented" do
        expect{BadlyFormedResolution.normalize}.to raise_error
      end

      it "disregards already registered resolutions" do
        expect { Tabs::Resolution.register(:minute, Tabs::Resolutions::Minute) }.to_not raise_error
      end
    end
  end

  describe "#unregister" do
    it "unregisters a single resolution" do
      Tabs::Resolution.unregister(:minute)
      expect(Tabs::Resolution.all).to_not include(:minute)
    end

    it "unregisters an array of resolutions" do
      Tabs::Resolution.unregister([:minute, :hour])
      expect(Tabs::Resolution.all).to_not include(:hour)
      expect(Tabs::Resolution.all).to_not include(:minute)
    end

    it "disregards passing in an unrecognized resolution" do
      expect { Tabs::Resolution.unregister(:invalid_resolution) }.to_not raise_error
    end
  end
end
