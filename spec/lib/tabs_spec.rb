require "spec_helper"

describe Tabs do
  include Tabs::Storage

  describe ".create_metric" do

    it "raises an error if the type is invalid" do
      expect { Tabs.create_metric("foo", "foobar") }.to raise_error(Tabs::UnknownTypeError)
    end

    it "raises an error if the metric already exists" do
      Tabs.create_metric("foo", "counter")
      expect { Tabs.create_metric("foo", "counter") }.to raise_error(Tabs::DuplicateMetricError)
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

  describe ".counter_total" do

    it "returns the total for a counter metric" do
      Tabs.increment_counter("foo")
      expect(Tabs.counter_total("foo")).to eq 1
    end

    it "returns the value of the block if given and the metric doesn't exist" do
      expect(Tabs.counter_total("foo") { 42 }).to eq 42
    end

    it "raises an UnknownMetricError if no block is given and the metric does not exist" do
      expect { Tabs.counter_total("foo") }.to raise_error Tabs::UnknownMetricError
    end

  end

  describe ".get_metric" do

    it "returns the expected metric object" do
      Tabs.create_metric("foo", "counter")
      expect(Tabs.get_metric("foo")).to be_a_kind_of(Tabs::Metrics::Counter)
    end

  end

  describe ".list_metrics" do

    it "returns the list_metrics of metric names" do
      Tabs.create_metric("foo", "counter")
      Tabs.create_metric("bar", "value")
      expect(Tabs.list_metrics).to eq(["foo", "bar"])
    end

  end

  describe ".metric_exists?" do

    it "returns true if the metric exists" do
      Tabs.create_metric("foo", "counter")
      expect(Tabs.metric_exists?("foo")).to be_truthy
    end

    it "returns false if the metric does not exist" do
      expect(Tabs.metric_exists?("foo")).to be_falsey
    end

  end

  describe ".drop_metric" do

    before do
      Tabs.create_metric("foo", "counter")
    end

    it "removes the metric from the list_metrics" do
      Tabs.drop_metric!("foo")
      expect(Tabs.list_metrics).to_not include("foo")
    end

    it "results in metric_exists? returning false" do
      Tabs.drop_metric!("foo")
      expect(Tabs.metric_exists?("foo")).to be_falsey
    end

    it "calls drop! on the metric" do
      metric = double(:metric)
      allow(Tabs).to receive(:get_metric).and_return(metric)
      expect(metric).to receive(:drop!)
      Tabs.drop_metric!("foo")
    end

  end

  describe ".drop_all_metrics" do

    it "drops all metrics" do
      Tabs.create_metric("foo", "counter")
      Tabs.create_metric("bar", "value")
      Tabs.drop_all_metrics!
      expect(Tabs.metric_exists?("foo")).to be_falsey
      expect(Tabs.metric_exists?("bar")).to be_falsey
    end

  end

  describe ".increment_counter" do

    it "raises a Tabs::MetricTypeMismatchError if the metric is the wrong type" do
      Tabs.create_metric("foo", "value")
      expect { Tabs.increment_counter("foo") }.to raise_error(Tabs::MetricTypeMismatchError)
    end

    it "creates the metric if it doesn't exist" do
      expect(Tabs.metric_exists?("foo")).to be_falsey
      expect { Tabs.increment_counter("foo") }.to_not raise_error
      expect(Tabs.metric_exists?("foo")).to be_truthy
    end

    it "calls increment on the metric" do
      metric = Tabs.create_metric("foo", "counter")
      allow(Tabs).to receive(:get_metric).and_return(metric)
      expect(metric).to receive(:increment)
      Tabs.increment_counter("foo")
    end

  end

  describe ".record_value" do

    it "creates the metric if it doesn't exist" do
      expect(Tabs.metric_exists?("foo")).to be_falsey
      expect { Tabs.record_value("foo", 38) }.to_not raise_error
      expect(Tabs.metric_exists?("foo")).to be_truthy
    end

    it "raises a Tabs::MetricTypeMismatchError if the metric is the wrong type" do
      Tabs.create_metric("foo", "counter")
      expect { Tabs.record_value("foo", 27) }.to raise_error(Tabs::MetricTypeMismatchError)
    end

    it "calls record on the metric" do
      Timecop.freeze(Time.now.utc)
      metric = Tabs.create_metric("foo", "value")
      allow(Tabs).to receive(:get_metric).and_return(metric)
      expect(metric).to receive(:record).with(42, Time.now.utc)
      Tabs.record_value("foo", 42)
    end

  end

  describe ".list_metrics" do

    it "lists all metrics that are defined" do
      Tabs.create_metric("foo", "counter")
      Tabs.create_metric("bar", "counter")
      Tabs.create_metric("baz", "counter")
      expect(Tabs.list_metrics).to eq(["foo", "bar", "baz"])
    end

  end

  describe ".metric_type" do

    it "returns the type of a counter metric" do
      Tabs.create_metric("foo", "counter")
      expect(Tabs.metric_type("foo")).to eq("counter")
    end

    it "returns the type of a value metric" do
      Tabs.create_metric("bar", "value")
      expect(Tabs.metric_type("bar")).to eq("value")
    end

    it "returns the type of a task metric" do
      Tabs.create_metric("baz", "task")
      expect(Tabs.metric_type("baz")).to eq("task")
    end

  end

  describe ".drop_resolution_for_metric!" do
    it "raises unknown metric error if metric does not exist" do
      expect{ Tabs.drop_resolution_for_metric!(:invalid, :minute) }.to raise_error(Tabs::UnknownMetricError)
    end

    it "raises resolution missing error if resolution not registered" do
      Tabs.create_metric("baz", "value")
      expect{ Tabs.drop_resolution_for_metric!("baz", :invalid) }.to raise_error(Tabs::ResolutionMissingError)
    end

    it "does not allow you to call drop_by_resolution if task metric" do
      metric = Tabs.create_metric("baz", "task")
      expect(metric).to_not receive(:drop_by_resolution!)
      Tabs.drop_resolution_for_metric!("baz", :minute)
    end

    it "drops the metric by resolution" do
      now = Time.utc(2000,1,1)
      metric = Tabs.create_metric("baz", "value")
      metric.record(42, now)
      Tabs.drop_resolution_for_metric!("baz", :minute)
      minute_key = Tabs::Metrics::Value.new("baz").storage_key(:minute, now)
      expect(Tabs::Storage.exists(minute_key)).to be_falsey
    end
  end

end
