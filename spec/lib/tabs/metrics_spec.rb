require "spec_helper"

describe Tabs::Metrics do

  describe "#create" do

    it "raises an error if the type is invalid" do
      lambda { Tabs::Metrics.create("foo", "foobar") }.should raise_error(Tabs::Metrics::UnknownTypeError)
    end

    it "raises an error if the metric already exists" do
      Tabs::Metrics.create("foo", "counter")
      lambda { Tabs::Metrics.create("foo", "counter") }.should raise_error(Tabs::Metrics::DuplicateMetricError)
    end

    it "returns a Counter metric if 'counter' was the specified type" do
      expect(Tabs::Metrics.create("foo", "counter")).to be_a_kind_of(Tabs::Metrics::Counter)
    end

    it "returns a Value metric if 'value' was the specified type" do
      expect(Tabs::Metrics.create("foo", "value")).to be_a_kind_of(Tabs::Metrics::Value)
    end

    it "adds the metric's key to the list" do
      Tabs::Metrics.create("foo", "value")
      Tabs::Metrics.create("bar", "counter")
      expect(Tabs::Metrics.list).to include("foo")
      expect(Tabs::Metrics.list).to include("bar")
    end

  end

  

end
