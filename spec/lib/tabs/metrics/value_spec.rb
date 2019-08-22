require "spec_helper"

describe Tabs::Metrics::Value do

  include Tabs::Storage

  let(:metric) { Tabs.create_metric("foo", "value") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }

  describe ".record" do

    before { Timecop.freeze(now) }

    it "sets the expected values for the period" do
      metric.record(17)
      metric.record(42)
      time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = metric.stats(((now - 2.hours)..(now + 4.hours)), :hour)
      expect(stats).to include({ "timestamp"=>time, "count"=>2, "min"=>17, "max"=>42, "sum"=>59, "avg"=>29.5})
    end

    it "applys the value to the specified timestamp if one is supplied" do
      time = Time.utc(now.year, now.month, now.day, now.hour) - 2.hours
      metric.record(42, time)
      stats = metric.stats(((now - 3.hours)..now), :hour)
      expect(stats).to include({ "timestamp"=>time, "count"=>1, "min"=>42, "max"=>42, "sum"=>42, "avg"=>42})
    end

  end

  describe ".stats" do

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    def create_span(time_unit)
      metric.record(5)
      Timecop.freeze(now + 1.send(time_unit))
      metric.record(25)
      Timecop.freeze(now + 3.send(time_unit))
      metric.record(10)
      Timecop.freeze(now + 6.send(time_unit))
      metric.record(15)
      metric.record(20)
      Timecop.freeze(now)
    end

    it "returns an instance of Tabs::Metrics::Value::Stats" do
      create_span(:minutes)
      stats = metric.stats(now..(now + 7.minutes), :minute)
      expect(stats).to be_a_kind_of Tabs::Metrics::Value::Stats
    end

    it "returns the expected results for an minutely metric" do
      create_span(:minutes)
      stats = metric.stats(now..(now + 7.minutes), :minute)
      expect(stats).to include({ "timestamp" => (now + 3.minutes), "count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10})
      expect(stats).to include({ "timestamp" => (now + 6.minutes), "count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17.5})
    end

    it "returns the expected results for an hourly metric" do
      create_span(:hours)
      stats = metric.stats(now..(now + 7.hours), :hour)
      expect(stats).to include({ "timestamp" => (now + 3.hours), "count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10})
      expect(stats).to include({ "timestamp" => (now + 6.hours), "count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17.5})
    end

    it "returns the expected results for a daily metric" do
      create_span(:days)
      stats = metric.stats(now..(now + 7.days), :day)
      expect(stats).to include({ "timestamp" => (now + 3.days), "count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10})
      expect(stats).to include({ "timestamp" => (now + 6.days), "count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17.5})
    end

    it "returns the expected results for a weekly metric" do
      create_span(:weeks)
      stats = metric.stats(now..(now + 7.weeks), :week)
      second_week_stats = stats.detect{|s| s["timestamp"] == (now + 1.week).beginning_of_week }
      expect(second_week_stats["count"]).to eq(1)
      expect(stats).to include({ "timestamp" => (now + 3.weeks).beginning_of_week, "count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10})
      expect(stats).to include({ "timestamp" => (now + 6.weeks).beginning_of_week, "count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17.5})
    end

    it "returns the expected results for a monthly metric" do
      create_span(:months)
      stats = metric.stats(now..(now + 7.months), :month)
      expect(stats).to include({ "timestamp" => (now + 3.months), "count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10})
      expect(stats).to include({ "timestamp" => (now + 6.months), "count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17.5})
    end

    it "returns the expected results for a yearly metric" do
      create_span(:years)
      stats = metric.stats(now..(now + 7.years), :year)
      expect(stats).to include({ "timestamp" => (now + 3.years), "count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10})
      expect(stats).to include({ "timestamp" => (now + 6.years), "count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17.5})
    end
  end

  describe ".drop!" do

    before do
      3.times { metric.record(rand(30)) }
      @count_keys = (Tabs::Resolution.all.map do |res|
        smembers("stat:value:foo:keys:#{res}")
      end).flatten
      metric.drop!
    end

    it "deletes all resolution count keys" do
      @count_keys.each do |key|
        expect(exists(key)).to be_falsey
      end
    end

    it "deletes all resolution key collection keys" do
      Tabs::Resolution.all.each do |res|
        expect(exists("stat:value:foo:keys:#{res}")).to be_falsey
      end
    end

  end

  describe ".drop_by_resolution!" do
    before do
      Timecop.freeze(now)
      2.times { metric.record(rand(30)) }
      metric.drop_by_resolution!(:minute)
    end

    it "deletes all metrics for a resolution" do
      stats = metric.stats((now - 1.minute)..(now + 1.minute), :minute)
      expect(stats.sum).to eq(0)
    end
  end

  describe "expiration of value metrics" do
    let(:expires_setting){ 6.hours }
    let(:now){ Time.utc(2050, 1, 1, 0, 0) }

    before do
      Tabs::Config.set_expirations({ minute: expires_setting })
    end

    after do
      Tabs::Config.reset_expirations
    end

    it "sets an expiration when recording a value" do
      metric.record(17, now)
      redis_expire_date = Time.now + Tabs::Storage.ttl(metric.storage_key(:minute, now))
      expire_date = now + expires_setting + Tabs::Resolutions::Minute.to_seconds
      expect(redis_expire_date).to be_within(2.seconds).of(expire_date)
    end
  end
end
