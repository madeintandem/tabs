require "spec_helper"

describe Tabs::Metrics::Counter do

  include Tabs::Storage

  let(:metric) { Tabs.create_metric("foo", "counter") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }

  describe "incrementing stats" do

    before { Timecop.freeze(now) }

    it "increments the value for the expected periods" do
      metric.increment
      time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = metric.stats(((now - 2.hours)..(now + 4.hours)), :hour)
      expect(stats).to include({ "timestamp" => time, "count" => 1 })
    end

    it "applys the increment to the specified timestamp if one is supplied" do
      time = Time.utc(now.year, now.month, now.day, now.hour) - 2.hours
      metric.increment(time)
      stats = metric.stats(((now - 3.hours)..now), :hour)
      expect(stats).to include({ "timestamp" => time, "count" => 1 })
    end

  end

  describe "total count" do

    it "is incremented every time regardless of resolution" do
      30.times { metric.increment }
      expect(metric.total).to eq(30)
    end

  end

  describe "retrieving stats" do

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    def create_span(time_unit)
      metric.increment
      Timecop.freeze(now + 3.send(time_unit))
      metric.increment
      Timecop.freeze(now + 6.send(time_unit))
      metric.increment
      metric.increment
      Timecop.freeze(now)
    end

    it "returns the expected results for an minutely metric" do
      create_span(:minute)
      stats = metric.stats(now..(now + 7.minutes), :minute)
      expect(stats).to include({ "timestamp" => (now + 3.minutes), "count" => 1 })
      expect(stats).to include({ "timestamp" => (now + 6.minutes), "count" => 2 })
    end

    it "returns the expected results for an hourly metric" do
      create_span(:hours)
      stats = metric.stats(now..(now + 7.hours), :hour)
      expect(stats).to include({ "timestamp" => (now + 3.hours), "count" => 1 })
      expect(stats).to include({ "timestamp" => (now + 6.hours), "count" => 2 })
    end

    it "returns the expected results for a daily metric" do
      create_span(:days)
      stats = metric.stats(now..(now + 7.days), :day)
      expect(stats).to include({ "timestamp" => (now + 3.days), "count" => 1 })
      expect(stats).to include({ "timestamp" => (now + 6.days), "count" => 2 })
    end

    it "returns the expected results for a monthly metric" do
      create_span(:months)
      stats = metric.stats(now..(now + 7.months), :month)
      expect(stats).to include({ "timestamp" => (now + 3.months), "count" => 1 })
      expect(stats).to include({ "timestamp" => (now + 6.months), "count" => 2 })
    end

    it "returns the expected results for a yearly metric" do
      create_span(:years)
      stats = metric.stats(now..(now + 7.years), :year)
      expect(stats).to include({ "timestamp" => (now + 3.years), "count" => 1 })
      expect(stats).to include({ "timestamp" => (now + 6.years), "count" => 2 })
    end

    it "returns zeros for time periods which do not have any events" do
      create_span(:days)
      stats = metric.stats(now..(now + 7.days), :day)
      expect(stats).to include({ "timestamp" => (now + 1.day), "count" => 0 })
    end

    context "for weekly metrics" do

      let(:period) do
        (now - 2.days)..((now + 7.weeks) + 2.days)
      end

      it "returns the expected results for a weekly metric" do
        create_span(:weeks)
        stats = metric.stats(period, :week)
        expect(stats).to include({ "timestamp" => (now + 3.weeks).beginning_of_week, "count" => 1 })
        expect(stats).to include({ "timestamp" => (now + 6.weeks).beginning_of_week, "count" => 2 })
      end

      it "normalizes the period to the first day of the week" do
        create_span(:weeks)
        stats = metric.stats(period, :week)
        expect(stats.first["timestamp"]).to eq(period.first.beginning_of_week)
        expect(stats.last["timestamp"]).to eq(period.last.beginning_of_week)
      end

    end

  end

  describe ".drop!" do

    before do
      3.times { metric.increment }
      expect(exists("stat:counter:foo:total")).to be_true
      @count_keys = (Tabs::RESOLUTIONS.map do |res|
        smembers("stat:counter:foo:keys:#{res}")
      end).flatten
      metric.drop!
    end

    it "deletes the counter total key" do
      expect(exists("stat:counter:foo:total")).to be_false
    end

    it "deletes all resolution count keys" do
      @count_keys.each do |key|
        expect(exists(key)).to be_false
      end
    end

    it "deletes all resolution key collection keys" do
      Tabs::RESOLUTIONS.each do |res|
        expect(exists("stat:counter:foo:keys:#{res}")).to be_false
      end
    end

  end

end
