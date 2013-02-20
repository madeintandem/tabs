require "spec_helper"

describe Tabs::Metrics::Counter do

  let(:metric) { Tabs.create_metric("foo", "counter") }
  let(:now) { Time.utc(2000, 1, 1, 0, 0) }

  describe ".increment" do

    it "increments the value for the expected periods" do
      Timecop.freeze(now)
      metric.increment
      time = Time.utc(now.year, now.month, now.day, now.hour)
      stats = metric.stats(((now - 2.hours)..(now + 4.hours)), :hour)
      expect(stats).to include({ time => 1 })
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
      expect(stats).to include({ (now + 3.minutes) => 1 })
      expect(stats).to include({ (now + 6.minutes) => 2 })
    end

    it "returns the expected results for an hourly metric" do
      create_span(:hours)
      stats = metric.stats(now..(now + 7.hours), :hour)
      expect(stats).to include({ (now + 3.hours) => 1 })
      expect(stats).to include({ (now + 6.hours) => 2 })
    end

    it "returns the expected results for a daily metric" do
      create_span(:days)
      stats = metric.stats(now..(now + 7.days), :day)
      expect(stats).to include({ (now + 3.days) => 1 })
      expect(stats).to include({ (now + 6.days) => 2 })
    end

    it "returns the expected results for a weekly metric" do
      create_span(:weeks)
      stats = metric.stats(now..(now + 7.weeks), :week)
      expect(stats).to include({ (now + 3.weeks).beginning_of_week => 1 })
      expect(stats).to include({ (now + 6.weeks).beginning_of_week => 2 })
    end

    it "returns the expected results for a monthly metric" do
      create_span(:months)
      stats = metric.stats(now..(now + 7.months), :month)
      expect(stats).to include({ (now + 3.months) => 1 })
      expect(stats).to include({ (now + 6.months) => 2 })
    end

    it "returns the expected results for a yearly metric" do
      create_span(:years)
      stats = metric.stats(now..(now + 7.years), :year)
      expect(stats).to include({ (now + 3.years) => 1 })
      expect(stats).to include({ (now + 6.years) => 2 })
    end

  end

end
