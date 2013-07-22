require "spec_helper"

describe Tabs::Metrics::Counter::Stats do

  let(:period) { (Time.now - 2.days..Time.now) }
  let(:resolution) { :hour }
  let(:values) do
    [
      { "timestamp" => Time.now - 30.hours, "count" => 44 },
      { "timestamp" => Time.now - 20.hours, "count" => 123 },
      { "timestamp" => Time.now - 10.hours, "count" => 92 }
    ]
  end
  let(:stats) { Tabs::Metrics::Counter::Stats.new(period, resolution, values) }

  it "is enumerable" do
    expect(stats).to respond_to :each
    expect(Tabs::Metrics::Counter::Stats.ancestors).to include Enumerable
  end

  it "#total returns the total count for the entire set" do
    expect(stats.total).to eq 259
  end

  it "min returns the min for the entire set" do
    expect(stats.min).to eq 44
  end

  it "max returns the max for the entire set" do
    expect(stats.max).to eq 123
  end

  it "avg returns the average for the entire set" do
    expect(stats.avg).to eq 86.33333
  end

end
