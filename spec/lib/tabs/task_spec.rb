require "spec_helper"

describe Tabs::Metrics::Task do

  let(:metric) { Tabs.create_metric("foo", "task") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }
  let(:token_1) { "2gd7672gjh3" }
  let(:token_2) { "17985jh34gj" }

  describe ".start" do

  end

  describe ".complete" do

    it "raises an UnstartedTaskMetricError if the metric has not yet been started" do
      lambda { metric.complete("foobar") }.should raise_error(Tabs::Metrics::Task::UnstartedTaskMetricError)
    end

  end

  describe ".stats" do

    it "returns the expected value" do
      Timecop.freeze(now)
      metric.start(token_1)
      metric.start(token_2)
      Timecop.freeze(now + 2.minutes)
      metric.complete(token_1)
      stats = metric.stats((now - 5.minutes)..(now + 5.minutes), :minute)
      expect(stats).to eq(
        {
          started: 2,
          completed: 1,
          completed_within_period: 1,
          completion_rate: 0.09
        }
      )
    end

  end

end
