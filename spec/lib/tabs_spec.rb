require "spec_helper"

describe Tabs do

  describe "#create_metric" do

    it "adds the expected list key for a counter metric" do
      Tabs.create_metric("foo", "counter")
    end

    it "adds the expected list key for a value metric" do
      Tabs.create_metric("foo", "value")
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

  describe "#stats" do

    it "returns []" do
      expect(Tabs.stats("foo")).to eq([])
    end

  end

end
