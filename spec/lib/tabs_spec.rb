require "spec_helper"

describe Tabs do
  include Tabs::Storage

  describe "#create_metric" do

    it "raises an error if the type is invalid" do
      lambda { Tabs.create_metric("foo", "foobar") }.should raise_error(Tabs::UnknownTypeError)
    end

    it "raises an error if the metric already exists" do
      Tabs.create_metric("foo", "counter")
      lambda { Tabs.create_metric("foo", "counter") }.should raise_error(Tabs::DuplicateMetricError)
    end

    it "returns a Counter metric if 'counter' was the specified type" do
      expect(Tabs.create_metric("foo", "counter")).to be_a_kind_of(Tabs::Metrics::Counter)
    end

    it "returns a Value metric if 'value' was the specified type" do
      expect(Tabs.create_metric("foo", "value")).to be_a_kind_of(Tabs::Metrics::Value)
    end

    it "adds the metric's key to the list_metrics" do
      Tabs.create_metric("foo", "value")
      Tabs.create_metric("bar", "counter")
      Tabs.create_metric("baz", "task")
      expect(Tabs.list_metrics).to include("foo")
      expect(Tabs.list_metrics).to include("bar")
      expect(Tabs.list_metrics).to include("baz")
    end

  end

  describe "#get_metric" do

    it "returns the expected metric object" do
      Tabs.create_metric("foo", "counter")
      expect(Tabs.get_metric("foo")).to be_a_kind_of(Tabs::Metrics::Counter)
    end

  end

  describe "#list_metrics" do

    it "returns the list_metrics of metric names" do
      Tabs.create_metric("foo", "counter")
      Tabs.create_metric("bar", "value")
      expect(Tabs.list_metrics).to eq(["foo", "bar"])
    end

  end

  describe "#metric_exists?" do

    it "returns true if the metric exists" do
      Tabs.create_metric("foo", "counter")
      expect(Tabs.metric_exists?("foo")).to be_true
    end

    it "returns false if the metric does not exist" do
      expect(Tabs.metric_exists?("foo")).to be_false
    end

  end

  describe "#drop_metric" do

    before do
      Tabs.create_metric("foo", "counter")
    end

    it "removes the metric from the list_metrics" do
      Tabs.drop_metric("foo")
      expect(Tabs.list_metrics).to_not include("foo")
      expect(Tabs.metric_exists?("foo")).to be_false
    end

    it "removes the metrics values from redis" do
      Tabs.increment_counter("foo")
      keys = smembers("tabs:stat:keys:foo:hour")
      expect(redis.keys).to include("tabs:stat:keys:foo:hour")
      Tabs.drop_metric("foo")
      expect(redis.keys).to_not include(keys[0])
    end

  end

  describe "#increment_counter" do

    it "raises a Tabs::MetricTypeMismatchError if the metric is the wrong type" do
      Tabs.create_metric("foo", "value")
      lambda { Tabs.increment_counter("foo") }.should raise_error(Tabs::MetricTypeMismatchError)
    end

    it "creates the metric if it doesn't exist" do
      expect(Tabs.metric_exists?("foo")).to be_false
      lambda { Tabs.increment_counter("foo") }.should_not raise_error
      expect(Tabs.metric_exists?("foo")).to be_true
    end

    it "calls increment on the metric" do
      metric = Tabs.create_metric("foo", "counter")
      Tabs.stub(get_metric: metric)
      metric.should_receive(:increment)
      Tabs.increment_counter("foo")
    end

  end

  describe "#record_value" do

    it "creates the metric if it doesn't exist" do
      expect(Tabs.metric_exists?("foo")).to be_false
      lambda { Tabs.record_value("foo", 38) }.should_not raise_error
      expect(Tabs.metric_exists?("foo")).to be_true
    end

    it "raises a Tabs::MetricTypeMismatchError if the metric is the wrong type" do
      Tabs.create_metric("foo", "counter")
      lambda { Tabs.record_value("foo", 27) }.should raise_error(Tabs::MetricTypeMismatchError)
    end

    it "calls record on the metric" do
      metric = Tabs.create_metric("foo", "value")
      Tabs.stub(get_metric: metric)
      metric.should_receive(:record).with(42)
      Tabs.record_value("foo", 42)
    end

  end

  describe "#list_metrics" do

    it "lists all metrics that are defined" do
      Tabs.create_metric("foo", "counter")
      Tabs.create_metric("bar", "counter")
      Tabs.create_metric("baz", "counter")
      expect(Tabs.list_metrics).to eq(["foo", "bar", "baz"])
    end
    
  end

  describe "#metric_type" do

    it "returns the type of a given metric" do
      Tabs.create_metric("foo", "counter")
      Tabs.create_metric("bar", "value")
      expect(Tabs.metric_type("foo")).to eq("counter")
      expect(Tabs.metric_type("bar")).to eq("value")
    end

  end

end
