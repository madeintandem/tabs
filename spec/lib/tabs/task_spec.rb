require "spec_helper"

describe Tabs::Metrics::Task do

  let(:metric) { Tabs.create_metric("foo", "task") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }
  let(:token_1) { "2gd7672gjh3" }
  let(:token_2) { "17985jh34gj" }
  let(:token_3) { "27f98fhgh1x" }

  describe ".start" do

    let(:token) { stub(:token) }
    let(:time) { Time.now }

    it "calls start on the given token" do
      Tabs::Metrics::Task::Token.should_receive(:new).with(token_1, "foo").and_return(token)
      token.should_receive(:start)
      metric.start(token_1)
    end

    it "passes through the specified timestamp" do
      Tabs::Metrics::Task::Token.stub(new: token)
      token.should_receive(:start).with(time)
      metric.start(token_1, time)
    end

  end

  describe ".complete" do

    let(:token) { stub(:token) }
    let(:time) { Time.now }

    it "calls complete on the given token" do
      token = stub(:token)
      Tabs::Metrics::Task::Token.should_receive(:new).with(token_1, "foo").and_return(token)
      token.should_receive(:complete)
      metric.complete(token_1)
    end

    it "passes through the specified timestamp" do
      Tabs::Metrics::Task::Token.stub(new: token)
      token.should_receive(:complete).with(time)
      metric.complete(token_1, time)
    end

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
      metric.start(token_3)
      Timecop.freeze(now + 3.minutes)
      metric.complete(token_3)
      stats = metric.stats((now - 5.minutes)..(now + 5.minutes), :minute)
      expect(stats.started_within_period).to eq 3
      expect(stats.completed_within_period).to eq 2
      expect(stats.started_and_completed_within_period).to eq 2
      expect(stats.completion_rate).to eq 0.18182
      expect(stats.average_completion_time).to eq 1.5
    end

  end

end
