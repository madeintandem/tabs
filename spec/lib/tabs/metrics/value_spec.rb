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
      expect(stats).to include({ time => {"count"=>2, "min"=>17, "max"=>42, "sum"=>59, "avg"=>29} })
    end

    it "applys the value to the specified timestamp if one is supplied" do
      time = Time.utc(now.year, now.month, now.day, now.hour) - 2.hours
      metric.record(42, time)
      stats = metric.stats(((now - 3.hours)..now), :hour)
      expect(stats).to include({ time => {"count"=>1, "min"=>42, "max"=>42, "sum"=>42, "avg"=>42} })
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
      Timecop.freeze(now + 3.send(time_unit))
      metric.record(10)
      Timecop.freeze(now + 6.send(time_unit))
      metric.record(15)
      metric.record(20)
      Timecop.freeze(now)
    end

    it "returns the expected results for an minutely metric" do
      create_span(:minutes)
      stats = metric.stats(now..(now + 7.minutes), :minute)
      expect(stats).to include({ (now + 3.minutes) => {"count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10} })
      expect(stats).to include({ (now + 6.minutes) => {"count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17} })
    end

    it "returns the expected results for an hourly metric" do
      create_span(:hours)
      stats = metric.stats(now..(now + 7.hours), :hour)
      expect(stats).to include({ (now + 3.hours) => {"count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10} })
      expect(stats).to include({ (now + 6.hours) => {"count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17} })
    end

    it "returns the expected results for a daily metric" do
      create_span(:days)
      stats = metric.stats(now..(now + 7.days), :day)
      expect(stats).to include({ (now + 3.days) => {"count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10} })
      expect(stats).to include({ (now + 6.days) => {"count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17} })
    end

    it "returns the expected results for a weekly metric" do
      create_span(:weeks)
      stats = metric.stats(now..(now + 7.weeks), :week)
      expect(stats).to include({ (now + 3.weeks).beginning_of_week => {"count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10} })
      expect(stats).to include({ (now + 6.weeks).beginning_of_week => {"count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17} })
    end

    it "returns the expected results for a monthly metric" do
      create_span(:months)
      stats = metric.stats(now..(now + 7.months), :month)
      expect(stats).to include({ (now + 3.months) => {"count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10} })
      expect(stats).to include({ (now + 6.months) => {"count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17} })
    end

    it "returns the expected results for a yearly metric" do
      create_span(:years)
      stats = metric.stats(now..(now + 7.years), :year)
      expect(stats).to include({ (now + 3.years) => {"count"=>1, "min"=>10, "max"=>10, "sum"=>10, "avg"=>10} })
      expect(stats).to include({ (now + 6.years) => {"count"=>2, "min"=>15, "max"=>20, "sum"=>35, "avg"=>17} })
    end

  end

  describe ".drop!" do

    before do
      3.times { metric.record(rand(30)) }
      @count_keys = (Tabs::RESOLUTIONS.map do |res|
        smembers("stat:value:foo:keys:#{res}")
      end).flatten
      metric.drop!
    end

    it "deletes all resolution count keys" do
      @count_keys.each do |key|
        expect(exists(key)).to be_false
      end
    end

    it "deletes all resolution key collection keys" do
      Tabs::RESOLUTIONS.each do |res|
        expect(exists("stat:value:foo:keys:#{res}")).to be_false
      end
    end

  end

end
