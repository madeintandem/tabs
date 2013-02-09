require "spec_helper"

describe Tabs do

  describe "#create_metric" do

    it "returns true if the metric type is valid" do
      expect(Tabs.create_metric("foo", "counter")).to be_true
      expect(Tabs.create_metric("foo", "value")).to be_true
    end

    it "raises an exception if the metric type is invalid" do
      lambda { Tabs.create_metric("foo", "unknown") }.should raise_error
    end

  end

  describe "#increment" do

    it "should return true" do
      expect(Tabs.increment("foo")).to be_true
    end

  end

  describe "#record" do

    it "should return true" do
      expect(Tabs.record("foo", 10)).to be_true
    end

  end

  describe "#get_values" do

    it "should return []" do
      expect(Tabs.get_values("foo")).to eq([])
    end

  end

end
